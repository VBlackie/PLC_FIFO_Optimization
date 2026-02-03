PROGRAM main
VAR
	My_Bad_FIFO : FB_FIFO;
	My_Good_FIFO : CIRCULAR_QUEUE;
	pb_Push : bool;
	pb_Pop : bool;
	Input_Data : int;
	Output_Bad : int AT %QW1;
	Output_Good : int AT %QW4;
	Test_value : int AT %QW5;
	Queue_Count : int AT %QW0;
	Shift_Counter : int AT %QW3;
	Shift_Counter_Good : int AT %QW2;
	Auto_TImer : TON;
	Test_Step : int := 0;
	Auto_Start : bool := FALSE;
	Fill_Queue_Now : bool := FALSE;
	i : int := 0;
	Queue_Count_Good : int := 0;
END_VAR

(* ============================================================= *)
(* ZONE 1: THE STRESS TEST LOADER (Instant Fill) *)
(* ============================================================= *)
(* This logic only runs ONCE when you force 'Fill_Queue_Now' to TRUE. *)
(* It pauses the scan cycle, stuffs 5,000 items into the queues, *)
(* and then releases the PLC back to normal operation. *)

IF Fill_Queue_Now THEN
    
    (* Loop from 1 to 5000 to fill the array completely *)
    FOR i := 1 TO 5000 DO
        
        (* 1. SIMULATE RISING EDGE (Push Button Press) *)
        (* We call the FBs directly here to force the data in *)
        My_Bad_FIFO(xPush := TRUE, xPop := FALSE, iInputVal := i);
        My_Good_FIFO(xPush := TRUE, xPop := FALSE, iInputVal := i);
        
        (* 2. SIMULATE FALLING EDGE (Push Button Release) *)
        (* We must call them again with FALSE to reset the trigger for the next loop iteration *)
        My_Bad_FIFO(xPush := FALSE, xPop := FALSE, iInputVal := i);
        My_Good_FIFO(xPush := FALSE, xPop := FALSE, iInputVal := i);
        
    END_FOR;
    
    (* Reset the trigger so it doesn't run forever *)
    Fill_Queue_Now := FALSE;
    
END_IF;


(* ============================================================= *)
(* ZONE 2: NORMAL OPERATION (Manual Pop) *)
(* ============================================================= *)
(* This runs every single scan cycle. It listens to your manual *)
(* 'pb_Pop' button so you can trigger the unloads when ready. *)

(* Call the Bad FIFO (Linear Shift) *)
My_Bad_FIFO(
    xPush := pb_Push,      (* Normal button control *)
    xPop := pb_Pop,        (* Normal button control *)
    iInputVal := Input_Data,
    iOutputVal => Output_Bad,
    iCount => Queue_Count,
    Operation_Cost => Shift_Counter
);

(* Call the Good FIFO (Circular Buffer) *)
My_Good_FIFO(
    xPush := pb_Push,
    xPop := pb_Pop,
    iInputVal := Input_Data,
    iOutputVal => Output_Good,
    iCount => Queue_Count_Good,
    Operation_Cost => Shift_Counter_Good
);

END_PROGRAM