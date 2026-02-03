FUNCTION_BLOCK FB_FIFO
VAR_INPUT
	XPush : bool;
	XPop : bool;
	iInputVal : int;
END_VAR

VAR_OUTPUT
	iOutputVal : int;
	iCount : int;
	Operation_Cost : int;
END_VAR

VAR
	Buffer : ARRAY [0..4999] OF INT;
	i : int;
	R_Trig_Push : R_TRIG;
	R_Trig_Pop : R_TRIG;
END_VAR

(* Edge Detection *)
R_Trig_Push(CLK := xPush);
R_Trig_Pop(CLK := xPop);

(* --- PUSH (FFL) --- *)
(* Simply add to the end. This part is actually fast (O(1)) *)
IF R_Trig_Push.Q AND iCount < 5000 THEN
    Buffer[iCount] := iInputVal;
    iCount := iCount + 1;
END_IF;

(* --- POP (FFU) - THE EXPENSIVE PART --- *)
(* This simulates the AB FFU shifting mechanism *)
IF R_Trig_Pop.Q AND iCount > 0 THEN
    
    (* 1. Grab the value at Head (Index 0) *)
    iOutputVal := Buffer[0];
    
    (* 2. THE SHIFT LOOP (The "Bad" Part) *)
    (* We must physically move every item down one slot *)
    (* If you have 50 items, this loop runs 49 times! *)
    
    FOR i := 0 TO iCount - 2 DO
        Buffer[i] := Buffer[i+1]; (* Move data from i+1 to i *)
        
        (* Increment the "Cost" Counter to visualize the inefficiency *)
        Operation_Cost := Operation_Cost + 1; 
    END_FOR;

    (* 3. Clear the last slot (optional, but clean) *)
    Buffer[iCount - 1] := 0;

    (* 4. Decrement Count *)
    iCount := iCount - 1;
    
END_IF;

END_FUNCTION_BLOCK