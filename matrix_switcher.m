%{
Purpose: Top-level script that controls the HP34970A device with HP34904A
    switching card. This script instantiates comms with the device and
    calls the function that indefinitely loops through the relays
    accociated with each soil box.

Variables that can be set:

    wait_time: this is the switching interval in seconds. If wait_time=30,
        then the program will switch between soil boxes every 30 seconds.
    address: This is the address of the HP34970 device. 
        To determine the address number, open the Keysight
        Connection Expert software on your PC and look for the VISA address
        that is listed for the device. It will look something like
        "GPIB0::11::INSTR" where the middle value is the address (in this
        case, 11). As an alternative, you can see and change the address on 
        the HP34970A itself using the following button combination: Shift >
        Sto/Rcl > Sto/Rcl. Press StoRcl again to exit back to the home
        screen. 

%}


clear all;
%% Variables that can be changed

address = 11;       % See note above about how to determine this value
% if you get an error saying "VISA: A timeout occurred", this value is probably wrong
                    
wait_time = 1;    % how many seconds to wait before switching to next sample


%% setup the instrument
open = instrfind('Status', 'open'); % see if instrument is open already
if ~isempty(open)   % if already open
    fclose(open);   % close it
end
instrument_string = "GPIB::" + address + "::INSTR"; % define instrument string

HP34970 = visa('keysight', instrument_string); % create a VISA object of the device
fopen(HP34970);     % open communications with the device

% time to run program = wait_time * 4 boxes * iterations

switching_loop(HP34970, wait_time); % loop through each soil sample
