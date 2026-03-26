function output = farray(input)

    Ts = input(:,1)
    Qw = input(:,2)

    output.T = 2 * Ts + Qw;



end