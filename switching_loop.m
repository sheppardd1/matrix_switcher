function switching_loop(HP34970, wait_time)

%{
Purpose: Loops through each soil box. This is done by opening each relay
associated with a soil box and waiting for wait_time seconds. Then, relays
for the soil box are opened and the process repeats for the 2nd soil box
(close relays, wait, open relays). See details at box

Variables: 
    HP34970: this is the visa object corresponding to the insttrument. It's
    used for communicating with the instrument.
    wait_time: the amount of time to wait between switching soil boxes
    (in seconds)

*** Notes ***
ASSUME: Each soil box will have 4 terminals going thru the matrix switcher

     Soil Box Number | Relay Numbers
    ---------------------------------
            1        |  211 and 222
            2        |  213 and 224
            3        |  215 and 226
            4        |  217 and 228

* Each relay can have 2 cables passing through it. 4 cables per box = 2
  relays per box.
* Open relay = open circuit (OFF), Closed relay = short circuit (ON)
* When determining the amount of time to wait between switching soil boxes,
  the code cannot just use the wait_time variable in the pualse() function
  because the code itself takes a nonzero amount of time to run. If the
  time taken for the code to run is not acocunted for, this time would
  accumulate to the point where the Miller Machine's readings are no longer
  in sync with the switching times (this could cause confusion about which
  soil boxes at being tested at which times). The amount of time to wait in
  the puase() function is given as:
    + current time (in epoch format)
    - amount of time that has been spend in the pause() function overall
    - start time (in epoch format)
  In this implementation, everything is done in reference to the start
  time, so if the wait_time is 2 seconds and the testing started at 12:00,
  then the first reading would be at 12:00, the 2nd at 12:02, ...the 5th at
  12:08, etc. 
%}
    
%%  initial setup
    % ensure all relays are open to start with
    set_relay(HP34970, "", "open_all");

    % write a log file with the times associated with each soil box.
    % Set the fopen() function's 2nd argument to 'a' to append to existing 
    % file or set it to 'w' to overwrite the existing file. (If there is no
    % existing file, a new one is created regardless of the option chosen).
    log_file = fopen('soil_log.txt','a');

    % print status to screen and log file
    message = "\nBegan Switching at " + string(datetime('now')) + "\n";
    fprintf(message);
    fprintf(log_file, message);
    
    start_time = clock;
    % make preparations for when program terminates (even if forceful ctrl+C)
    cleanupObj = onCleanup(@()cleanMeUp(log_file,start_time));

    
%%  Continuous Loop Through Soil Samples
    start_epoch_time = posixtime(datetime('now'));
    i = 0;
    while(true)
    
    % Soil Box #1
        fprintf(log_file, string(datetime('now')) + " Reading Soil Box #1\n");  % log time
        set_relay(HP34970, "211,222", "close");   % close relay for current soil box
        % wait while Miller Machine reads data (see notes at beginning
        % about why we can't just use the wait_time variable)
        pause(wait_time - (posixtime(datetime('now')) - i*4*wait_time - start_epoch_time));
        set_relay(HP34970, "211,222", "open");    % open relay for current soil box

    % Soil Box #2       % repeat the process for the other soil boxes
        fprintf(log_file, string(datetime('now')) + " Reading Soil Box #2\n");
        set_relay(HP34970, "213,224", "close");
        pause(wait_time - (posixtime(datetime('now')) - i*4*wait_time - wait_time - start_epoch_time));
        set_relay(HP34970, "213,224", "open");    % open relay for current soil box

    % Soil Box #3
        fprintf(log_file, string(datetime('now')) + " Reading Soil Box #3\n");
        set_relay(HP34970, "215,226", "close");
        pause(wait_time - (posixtime(datetime('now')) - i*4*wait_time - 2*wait_time - start_epoch_time));
        set_relay(HP34970, "215,226", "open");
        
    % Soil Box #4
        fprintf(log_file, string(datetime('now')) + " Reading Soil Box #4\n");
        set_relay(HP34970, "217,228", "close");
        pause(wait_time - (posixtime(datetime('now')) - i*4*wait_time - 3*wait_time - start_epoch_time));
        set_relay(HP34970, "217,228", "open");
        
        i = i+1;
    end
    
    
%%  Account for stopping conditions
    function cleanMeUp(log_file, start_time)
    % activates if user presses ctrl + C while this switching_loop function
    % is running. Ensures ending time is saved to log file and that file is
    % closed. Also ensures that the instrument is closed.
    
        % close comms with instrument
        open = instrfind('Status', 'open'); % see if instrument is still open
        if ~isempty(open)   % if still open
            fclose(open);   % close it
        end
        
        elapsed_time = etime(clock, start_time);
        % finish writing to log and close log file
        message2 = "Program Terminated at " + string(datetime('now')) + ...
            "\nElapsed Time: " + elapsed_time + " seconds\n";
        fprintf(message2);
        fprintf(log_file, message2);
        
        fclose(log_file);   % close the file
        
        % print success
        fprintf("\nEXIT SUCCESS\n\n");

    end    

end

