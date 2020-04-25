function set_relay(device, relay_number, state)
%{
Purpose: opens or closes a specific relay
Variables:
    device: the visa object of the device that you are using
    relay_number: the relay that needs to be opened/closed
        This can be:
            a number (e.g. 211)
            a range of consecutive numbers as a string (e.g. "211:224")
            a group of nonconsecutive numbers (e.g. "211, 213, 238")
        Quotation marks are needed if the latter two of these options is used
    state: the decision about what should happen to the relay
        open: opens the relay
        close: closes the relay
        open_all: opens all relays (the value of relay_number gets ignored)
        close_all: closes all relays (the value of relay_number gets ignored)

NOTES: this function doe not check to see if the relay exists because
there are many ways to input a relay (see notes on relay_number variable)
If an inputted relay does not exist, the switch unit will beep and display
and error notice on the screen in red. If mulpile relays were listed to set
and one of them does not exist, then all the others are ignored as well.

%}

% open specific relay
    if(state == "open")
        command = "ROUTe:OPEN (@" + relay_number + ")";
        fprintf(device, command);
        
% close specific relay
    elseif(state == "close")
        command = "ROUTe:CLOSe (@" + relay_number + ")";
        fprintf(device, command);
        
% open all relays
    elseif(state == "open_all")
        command = "ROUTe:OPEN (@211:248)";
        fprintf(device, command);
        
% close all relays
    elseif(state == "close_all")
        command = "ROUTe:CLOSe (@211:248)";
        fprintf(device, command);
        
% else state is wrong
    else
        fprintf("ERROR: INCORRECT INPUT TO set_relay().\nVARIABLE" + ... 
            " state MUST BE set to ""open"" OR ""close"" " + ...
            "OR ""open_all"" OR ""close_all""\n");
        beep;
    end

end


