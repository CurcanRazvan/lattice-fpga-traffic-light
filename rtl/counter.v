`timescale 1ns/1ps

// Semafor pentru masini si pietoni, cu buton pentru traversare
// Masinile stau pe verde pana apare o cerere.
// Dupa traversare au verde minim 10 secunde.

module counter #(
    parameter CLK_HZ   = 12_000_000,
    parameter T_ROSU   = 15,
    parameter T_VERDE  = 10,
    parameter T_GALBEN = 2
)(
    input clk_i,
    input rst_ni,
    input btn_i,

    output reg car_red_o,
    output reg car_yellow_o,
    output reg car_green_o,
    output reg ped_red_o,
    output reg ped_green_o
);

    localparam [2:0] INITIAL = 3'd0,
                     GREEN   = 3'd1,
                     YELLOW  = 3'd2,
                     RED     = 3'd3,
                     DONE    = 3'd4;

    reg [2:0] stare, stare_urm;

    localparam nrstop = CLK_HZ - 1;

    reg [31:0] numar;
    reg [7:0] sec;
    reg [7:0] durata;

    reg t_sync1, t_sync2;
    reg t_prev;
    reg cerere;

    // Sincronizare buton si detectie front crescator
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            t_sync1 <= 1'b0;
            t_sync2 <= 1'b0;
            t_prev  <= 1'b0;
        end
        else begin
            t_sync1 <= btn_i;
            t_sync2 <= t_sync1;
            t_prev  <= t_sync2;
        end
    end

    wire front = t_sync2 & ~t_prev;

    // Memorare cerere pieton
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            cerere <= 1'b0;
        else if (stare == DONE)
            cerere <= 1'b0;
        else if (front && stare != RED)
            cerere <= 1'b1;
    end

    // Durata fiecarei stari
    always @(*) begin
        case (stare)
            GREEN:   durata = T_VERDE;
            YELLOW:  durata = T_GALBEN;
            RED:     durata = T_ROSU;
            default: durata = 8'd0;
        endcase
    end

    wire tick = (numar == nrstop);
    wire timp_gata = tick && (sec == durata - 1);

    // Contoare de timp
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            numar <= 32'd0;
            sec   <= 8'd0;
        end
        else if (stare != stare_urm || stare == INITIAL) begin
            numar <= 32'd0;
            sec   <= 8'd0;
        end
        else if (tick) begin
            numar <= 32'd0;
            sec   <= sec + 8'd1;
        end
        else begin
            numar <= numar + 32'd1;
        end
    end

    // Registrul de stare
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            stare <= INITIAL;
        else
            stare <= stare_urm;
    end

    // Tranzitii FSM
    always @(*) begin
        stare_urm = stare;

        case (stare)
            INITIAL: if (cerere)    stare_urm = YELLOW;
            GREEN:   if (timp_gata) stare_urm = INITIAL;
            YELLOW:  if (timp_gata) stare_urm = RED;
            RED:     if (timp_gata) stare_urm = DONE;
            DONE:                   stare_urm = GREEN;
            default:                stare_urm = INITIAL;
        endcase
    end

    // Iesiri
    always @(*) begin
        car_red_o    = 1'b0;
        car_yellow_o = 1'b0;
        car_green_o  = 1'b0;
        ped_red_o    = 1'b1;
        ped_green_o  = 1'b0;

        case (stare)
            INITIAL: car_green_o  = 1'b1;
            GREEN:   car_green_o  = 1'b1;
            YELLOW:  car_yellow_o = 1'b1;

            RED: begin
                car_red_o   = 1'b1;
                ped_red_o   = 1'b0;
                ped_green_o = 1'b1;
            end

            DONE:    car_red_o = 1'b1;
            default: car_red_o = 1'b1;
        endcase
    end

endmodule