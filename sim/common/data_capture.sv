module data_capture #(
    parameter string    FILENAME     = "output_data.bin",
    parameter int       DATA_WIDTH   = 8,
    // Supported operational modes are:
    //  0 - None, never assert the ready signal
    //  1 - Assert the ready signal immediately after reset
    //  2 - Periodically assert and deassert the ready based on provided values
    //  3 - Randomly assert and deassert the ready
    parameter int       MODE         = 0,
    // Number of clocks to periodically assert the ready signal
    parameter int       ASSERT_CNT   = 5,
    // Number of clocks to periodically deassert the ready signal
    parameter int       DEASSERT_CNT = 5
) (
    // Clock and synchronous reset 
    input   logic       clk,
    input   logic       rst,

    // Bus interface to capture data from 
    input   logic       [(DATA_WIDTH - 1):0] data,
    input   logic       valid,
    output  logic       ready,

    // The initiator of the transaction needs to specify when the transmission is finished
    // so that the capture file is complete (typically provided by a testbench)
    input   logic       done
);

	int recv_fd;
	integer file_size = 0;
	integer cycle_cnt = 0;
	integer total_bytes = 0;
	
	integer random_assert_cnt;
	integer random_deassert_cnt;
	
	localparam NONE       = 0;
	localparam FULL       = 1;
	localparam PERIODIC   = 2;
	localparam RANDOM     = 3;
	
	initial begin
	    recv_fd = $fopen(FILENAME, "wb");
        if (recv_fd) begin
            $display("Opened %s for storing received data", FILENAME);
        end else begin
            $fatal(1, "Could not open %s for writing", FILENAME);
        end
        $fflush(recv_fd);
	end

    // Drive the ready signal for the appropriate mode
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            ready       <= 1'b0;
            cycle_cnt   <= 0;
        end else begin

            case (MODE)

            // Never assert ready, make the transaction initiator stall
            NONE: begin
                ready   <= 1'b0;
            end

            // Once out of resett, we're ready forever
            FULL: begin
                ready   <= 1'b1;
            end

            // Periodically deassert the ready for a certain number of clocks
            PERIODIC: begin
                if (cycle_cnt < ASSERT_CNT) begin
                    ready       <= 1'b1;
                    cycle_cnt   <= cycle_cnt + 1;
                end else if (cycle_cnt < (ASSERT_CNT + DEASSERT_CNT)) begin
                    ready       <= 1'b0;
                    cycle_cnt   <= cycle_cnt + 1;
                end else begin
                    cycle_cnt   <= 0;
                end
            end

            // Randomly deassert the ready for a certain number of clocks
            RANDOM: begin
                if ($random % 2 == 0) begin
                    ready       <= 1'b1;
                end else begin
                    ready       <= 1'b0;
                end
            end

            default: begin end

            endcase
        end
    end

    // Capture the data bus when valid and ready are true together. If we get
    // the done indicator, close the file.
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            total_bytes = 0;
        end else begin
            // Data moved on this edge
            if ( (valid == 1'b1) && (ready == 1'b1) ) begin
                // Accumulate the total number of bytes written to the open
                // file descriptor
                total_bytes += write_data(recv_fd, data);
            end 
            // If we're finished, close the file and print the total
            if (done == 1'b1) begin
                $write("Closing %s...", FILENAME);
                $fclose(recv_fd);
                $display("Wrote %0d bytes.", total_bytes);
            end
        end
    end

    // Write data to a file LSB first, returns number of bytes written to the
    // open file descriptor
    function automatic integer write_data(
        input   int fd,
        input   logic [(DATA_WIDTH - 1):0] data
    );
        integer i;
        integer num_bytes;
        integer total_bytes = 0;

        integer errno;
        string str;

        num_bytes = DATA_WIDTH / 8;

        // Write data LSB first, one byte at a time.
        for (i = 0; i < num_bytes; i++) begin
            $fwrite(fd, "%c", data[i*8 +: 8]);
            errno = $ferror(fd, str);
            if (errno) begin
                $fatal(1, str);
            end else begin
                total_bytes += num_bytes;
            end
        end
        $fflush(fd);
        return total_bytes;

    endfunction

endmodule
