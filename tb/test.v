`timescale 1ns/1ps

module test;

    localparam int CLK_HZ_SIM = 10;
    localparam time T_CLK = 10;
    localparam time SEC = CLK_HZ_SIM * T_CLK;

    logic clk_i;
    logic rst_ni;
    logic btn_i;

    logic car_red_o;
    logic car_yellow_o;
    logic car_green_o;
    logic ped_red_o;
    logic ped_green_o;

    int erori = 0;
    int nr_galben = 0;
    logic monitor_activ = 0;
    logic siguranta_ok = 1;
    time t_start;

    counter #(
        .CLK_HZ(CLK_HZ_SIM),
        .T_ROSU(15),
        .T_VERDE(10),
        .T_GALBEN(2)
    ) dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .btn_i(btn_i),

        .car_red_o(car_red_o),
        .car_yellow_o(car_yellow_o),
        .car_green_o(car_green_o),
        .ped_red_o(ped_red_o),
        .ped_green_o(ped_green_o)
    );

    // Clock
    initial begin
        clk_i = 0;
    end

    always #(T_CLK / 2) clk_i = ~clk_i;

    // Numar de traversari pornite
    always @(posedge car_yellow_o)
        nr_galben = nr_galben + 1;

    // Verificari de siguranta
    always @(posedge clk_i) begin
        #1;

        if (monitor_activ && siguranta_ok) begin

            if ((car_red_o + car_yellow_o + car_green_o) != 1) begin
                $display("EROARE: masinile nu au exact o culoare aprinsa");
                siguranta_ok = 0;
                erori = erori + 1;
            end

            if ((ped_red_o + ped_green_o) != 1) begin
                $display("EROARE: pietonii nu au exact o culoare aprinsa");
                siguranta_ok = 0;
                erori = erori + 1;
            end

            if (ped_green_o && !car_red_o) begin
                $display("EROARE: pietonii au verde, dar masinile nu au rosu");
                siguranta_ok = 0;
                erori = erori + 1;
            end

        end
    end

    task apasa_buton(input int cicluri);
        begin
            @(negedge clk_i);
            btn_i = 1;

            repeat (cicluri) @(negedge clk_i);
            btn_i = 0;
        end
    endtask

    task espera_secunde(input int n);
        begin
            repeat (n * CLK_HZ_SIM) @(posedge clk_i);
            #1;
        end
    endtask

    task verifica(
        input string nume,
        input logic mr,
        input logic mg,
        input logic mv,
        input logic pr,
        input logic pv
    );
        begin
            if ({car_red_o, car_yellow_o, car_green_o,
                 ped_red_o, ped_green_o} === {mr, mg, mv, pr, pv}) begin

                $display("OK: %s", nume);

            end
            else begin

                $display("EROARE: %s", nume);

                $display(
                    "asteptat: masini R/G/V = %b%b%b, pietoni R/V = %b%b",
                    mr, mg, mv, pr, pv
                );

                $display(
                    "primit: masini R/G/V = %b%b%b, pietoni R/V = %b%b",
                    car_red_o, car_yellow_o, car_green_o,
                    ped_red_o, ped_green_o
                );

                erori = erori + 1;

            end
        end
    endtask

    task verifica_durata(
        input string nume,
        input time primit,
        input time asteptat
    );
        begin
            if (primit == asteptat)
                $display("OK: %s = %0.1f s",
                         nume, primit * 1.0 / SEC);
            else begin
                $display("EROARE: %s = %0.1f s, asteptat %0.1f s",
                         nume,
                         primit * 1.0 / SEC,
                         asteptat * 1.0 / SEC);

                erori = erori + 1;
            end
        end
    endtask

    task verifica_minim(
        input string nume,
        input time primit,
        input time minim
    );
        begin
            if (primit >= minim)
                $display("OK: %s = %0.1f s",
                         nume, primit * 1.0 / SEC);
            else begin
                $display("EROARE: %s = %0.1f s, minim %0.1f s",
                         nume,
                         primit * 1.0 / SEC,
                         minim * 1.0 / SEC);

                erori = erori + 1;
            end
        end
    endtask

    task verifica_nr(
        input string nume,
        input int primit,
        input int asteptat
    );
        begin
            if (primit == asteptat)
                $display("OK: %s = %0d", nume, primit);
            else begin
                $display("EROARE: %s = %0d, asteptat %0d",
                         nume, primit, asteptat);

                erori = erori + 1;
            end
        end
    endtask

    initial begin

        rst_ni = 0;
        btn_i = 0;

        repeat (3) @(posedge clk_i);

        @(negedge clk_i);
        rst_ni = 1;

        #1;
        monitor_activ = 1;

        $display("----------------------------");
        $display("INCEPUT TEST SEMAFOR");
        $display("----------------------------");

        // TEST 1
        $display("");
        $display("TEST 1: dupa reset");

        verifica("masini verde, pietoni rosu",
                 0, 0, 1, 1, 0);

        // TEST 2
        $display("");
        $display("TEST 2: 30 s fara buton");

        espera_secunde(30);

        verifica("masini verde, pietoni rosu",
                 0, 0, 1, 1, 0);

        verifica_nr("nr de galben", nr_galben, 0);

        // TEST 3
        $display("");
        $display("TEST 3: traversare completa");

        apasa_buton(2);

        wait (car_yellow_o);

        t_start = $time;
        #1;

        verifica("masinile primesc galben",
                 0, 1, 0, 1, 0);

        wait (!car_yellow_o);

        verifica_durata(
            "galben masini",
            $time - t_start,
            2 * SEC
        );

        t_start = $time;
        #1;

        verifica("masini rosu, pietoni verde",
                 1, 0, 0, 0, 1);

        wait (!ped_green_o);

        verifica_durata(
            "verde pietoni",
            $time - t_start,
            15 * SEC
        );

        wait (car_green_o);

        t_start = $time;
        #1;

        verifica("masinile au din nou verde",
                 0, 0, 1, 1, 0);

        // TEST 4
        $display("");
        $display("TEST 4: apasare imediat dupa traversare");

        apasa_buton(2);

        espera_secunde(8);

        verifica("dupa 8 s masinile inca au verde",
                 0, 0, 1, 1, 0);

        wait (car_yellow_o);

        verifica_minim(
            "verde masini dupa traversare",
            $time - t_start,
            10 * SEC
        );

        // TEST 5
        $display("");
        $display("TEST 5: apasare cand pietonii au verde");

        wait (ped_green_o);

        espera_secunde(5);
        apasa_buton(3);

        wait (car_green_o);
        espera_secunde(35);

        verifica("masini verde, pietoni rosu",
                 0, 0, 1, 1, 0);

        verifica_nr(
            "nr de galben",
            nr_galben,
            2
        );

        // TEST 6
        $display("");
        $display("TEST 6: apasare in timpul galbenului");

        apasa_buton(2);

        wait (car_yellow_o);

        espera_secunde(1);
        apasa_buton(2);

        wait (car_green_o);
        espera_secunde(35);

        verifica_nr(
            "nr de galben",
            nr_galben,
            3
        );

        // TEST 7
        $display("");
        $display("TEST 7: buton tinut apasat");

        @(negedge clk_i);
        btn_i = 1;

        wait (car_yellow_o);
        wait (car_green_o);

        espera_secunde(35);

        @(negedge clk_i);
        btn_i = 0;

        espera_secunde(5);

        verifica_nr(
            "nr de galben",
            nr_galben,
            4
        );

        // TEST 8
        $display("");
        $display("TEST 8: reset in timpul traversarii");

        apasa_buton(2);

        wait (ped_green_o);
        espera_secunde(3);

        @(negedge clk_i);
        rst_ni = 0;

        #1;

        verifica("dupa reset: masini verde, pietoni rosu",
                 0, 0, 1, 1, 0);

        @(negedge clk_i);
        rst_ni = 1;

        espera_secunde(30);

        verifica("dupa reset nu a ramas nicio cerere",
                 0, 0, 1, 1, 0);

        verifica_nr(
            "nr de galben",
            nr_galben,
            5
        );

        $display("");

        if (siguranta_ok)
            $display("OK: verificarea continua nu a gasit probleme");

        $display("----------------------------");

        if (erori == 0)
            $display("SFARSIT TEST SEMAFOR: toate verificarile au trecut");
        else
            $display("SFARSIT TEST SEMAFOR: %0d erori", erori);

        $display("----------------------------");

        #20;
        $finish;
    end

    // Timeout
    initial begin
        #300000;

        $display("EROARE: timeout");
        $finish;
    end

endmodule