/*
    Serial AXI-3 Lite Protocol based memory (RAM)
    AXI-3 Lite supports serial reads and writes in burst format too. For tha sake of simplicity, this implementation doesn't involve burst transfers.

    This implementation supports simultaneous write and read operations, but serially!
*/

module s_axi3_lite (
    input logic s_axi3_clk, //Clock signal
    input logic s_axi3_rstn, //Reset signal for synchronous reset

    //WRITE CHANNELS
    //Write address channel
    input logic s_axi3_awvalid, // Master requests the slave for a write request.
    output logic s_axi3_awready, // Slave has received the request to write data to a particular address
    input logic [31:0] s_axi3_awaddr, //Input for writing to an ADDRESS.

    //Write Data channel
    input logic s_axi3_wvalid, //Master sends a reqeuest to the slave for writing the data sent in the s_axi3_wdata bus.
    output logic s_axi3_wready, //Slave sends a response to the s_axi3_wvalid request confirming that it has received s_axi3_wvalid and s_axi3_wdata.
    input logic [31:0] s_axi3_wdata, //Input for writing DATA to the corresponding address.

    //Write Response Channel
    output logic s_axi3_bvalid, // If the slave is ready with a response for a transaction, it informs the master by making this signal high.
    input logic s_axi3_bready, // As soon as master is ready to receive a response, it will make this signal high.
    output logic [1:0] s_axi3_bresp, //Response sent out by the slave corresponding to a particular transaction. For this implementation, I kept it simple by having two different states for responses - 00 (Ok!) and 11 (Decode error!)

    //READ CHANNELS
    //Read Address Channel
    input logic s_axi3_arvalid, //Master requests the slave for a read request from a particular address.
    output logic s_axi3_arready, //Slave responds to the master when it receives s_axi3_arvalid and s_axi3_araddr
    input logic [31:0] s_axi3_araddr, //Input for reading from an ADDRESS

    //Read Data Channel
    output logic s_axi3_rvalid, //When slave is ready with the data from the requested address, it will make this signal high.
    input logic s_axi3_rready, // When the master is ready to receive data, it will make this signal high.
    output logic [31:0] s_axi3_rdata, //Data read from the corresponding address location.
    output logic [1:0] s_axi3_rresp // Response of a read transaction (similar to write transaction)
);

    localparam IDLE = 0,
               SEND_WADDR_ACK = 1,
               SEND_WDATA_ACK = 2
               SEND_RADDR_ACK = 3,
               UPDATE_MEMORY = 4,
               SEND_WR_ERR = 5,
               SEND_WR_RESP = 6,
               GEN_DATA = 7,
               SEND_RD_ERR = 8,
               SEND_RDATA = 9;

    //State Register initialized to IDLE state waiting for a transaction
    logic [3:0] state = IDLE;

    logic [31:0] raddr, waddr, rdata, wdata;

    logic [1:0] count;

    //Memory Block that contains all the necessary data to feed into the systolic array.
    logic [31:0] axi3_memory [127:0];

    always@(posedge s_axi3_clk) begin
        if (!s_axi3_rstn) begin
            
            //Update state to idle
            state <= idle;

            //Reset the registers.
            raddr <= 0;
            waddr <= 0;
            rdata <= 0;
            wdata <= 0;

            //Reset the memory block to all 0s.
            for (int i = 0; i < 128; i++) begin
                axi3_memory[i] <= 0;
            end

            //Reset output signals of the memory block.
            s_axi3_awready <= 0;
            s_axi3_wready <= 0;
            s_axi3_wready <= 0;
            s_axi3_bvalid <= 0;
            s_axi3_wdata <= 0;
            s_axi3_bvalid <= 0;
            s_axi3_bresp <= 0;
            s_axi3_arready <= 0;
            s_axi3_rvalid <= 0;
            s_axi3_rdata <= 0;
            s_axi3_rresp <= 0;

        end
        else begin
            case (state)
                IDLE: begin
                    s_axi3_awready <= 0;
                    s_axi3_wready <= 0;
                    s_axi3_wready <= 0;
                    s_axi3_bvalid <= 0;
                    s_axi3_wdata <= 0;
                    s_axi3_bvalid <= 0;
                    s_axi3_bresp <= 0;
                    s_axi3_arready <= 0;
                    s_axi3_rvalid <= 0;
                    s_axi3_rdata <= 0;
                    s_axi3_rresp <= 0;
                    raddr <= 0;
                    waddr <= 0;
                    rdata <= 0;
                    wdata <= 0;
                    count <= 0;

                    if (s_axi3_awvalid) begin
                        state <= SEND_WADDR_ACK;
                        waddr <= s_axi3_awaddr;
                        s_axi3_awready <= 1;
                    end
                    else if (s_axi3_arvalid) begin
                        state <= SEND_RADDR_ACK;
                        raddr <= s_axi3_araddr;
                        s_axi3_arready <= 1;
                    end
                    else begin
                        state <= IDLE;
                    end
                end 

                SEND_WADDR_ACK: begin
                    s_axi3_awready <= 0;

                    if (s_axi3_wvalid) begin
                        state <= SEND_WDATA_ACK;
                        s_axi3_wready <= 1;
                        wdata <= s_axi3_wdata;
                    end
                    else begin
                        state <= SEND_WADDR_ACK;
                    end
                end

                SEND_WDATA_ACK: begin
                    s_axi3_wready <= 0;

                    if (waddr < 128) begin
                        state <= UPDATE_MEMORY;
                    end
                    else begin
                        state <= SEND_WR_ERR;
                        s_axi3_bresp <= 2'b11;
                        s_axi3_bvalid <= 1;
                    end
                end

                UPDATE_MEMORY: begin
                    axi3_memory[waddr] <= wdata;
                    state <= SEND_WR_RESP;
                end

                SEND_WR_RESP: begin
                    s_axi3_bresp <= 2'b00; //no errors (ok!)
                    s_axi3_bvalid <= 1;

                    if (s_axi3_bready) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= SEND_WR_RESP;
                    end
                end

                SEND_WR_ERR: begin
                    if (s_axi3_bready) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= SEND_WR_ERR;
                    end
                end

                SEND_RADDR_ACK: begin
                    s_axi3_arready <= 0;

                    if (raddr < 128) begin
                        state <= GEN_DATA;
                    end
                    else begin
                        state <= SEND_RD_ERR;
                        s_axi3_rdata <= 0;
                        s_axi3_rresp <= 2'b11;
                        s_axi3_rvalid <= 1;
                    end
                end

                //Takes "2" clock cycles to fetch the data.
                GEN_DATA: begin
                    if (count < 2) begin
                        count <= count + 1;
                        state <= GEN_DATA;
                        rdata <= axi3_memory[raddr];
                    end
                    else begin
                        s_axi3_rvalid <= 1;
                        s_axi3_rdata <= rdata;
                        s_axi3_rresp <= 2'b00;
                        if (s_axi3_rready) begin
                            state <= IDLE;
                        end
                        else begin
                            state <= GEN_DATA;
                        end
                    end
                end

                SEND_RD_ERR: begin
                    if (s_axi3_rready) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= SEND_RD_ERR;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
    
endmodule