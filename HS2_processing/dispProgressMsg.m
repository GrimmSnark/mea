function dispProgressMsg(msg)
ASCII_BKSP_CHAR = 8;
persistent prevMsgLen;
if isempty(prevMsgLen) 
    prevMsgLen = 0;
end
    
disp([ char(repmat(ASCII_BKSP_CHAR,1,prevMsgLen)) msg]);
prevMsgLen = numel(msg)+1;