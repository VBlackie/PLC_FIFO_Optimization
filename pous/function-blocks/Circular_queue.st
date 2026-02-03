FUNCTION_BLOCK Circular_queue
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
	Head : int;
	Tail : int;
	MaxLen : int;
	R_Trig_Push : R_TRIG;
	R_Trig_Pop : R_TRIG;
END_VAR

(* Edge Detection *)
R_Trig_Push(CLK := xPush);
R_Trig_Pop(CLK := xPop);

(* initialize MaxLen if 0 (safety check) *)
MaxLen := 5000;

(* --- PUSH (Enqueue) --- *)
IF R_Trig_Push.Q THEN
    (* Only push if not full (Optional safety, but good practice) *)
    IF iCount < MaxLen THEN
        Buffer[Head] := iInputVal;
        Head := Head + 1;
        IF Head >= MaxLen THEN Head := 0; END_IF;
        
        (* DIRECT COUNTING - The Fix *)
        iCount := iCount + 1; 
    END_IF;
END_IF;

(* --- POP (Dequeue) --- *)
IF R_Trig_Pop.Q AND iCount > 0 THEN
    iOutputVal := Buffer[Tail];
    Tail := Tail + 1;
    IF Tail >= MaxLen THEN Tail := 0; END_IF;
    
    (* DIRECT COUNTING - The Fix *)
    iCount := iCount - 1;
    Operation_Cost := 0; 
END_IF;

END_FUNCTION_BLOCK