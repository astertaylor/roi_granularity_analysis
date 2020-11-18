function checkerboard = control_creator(square,dim,value,wh_mean,wh_std)
    board = value*kron([[1, 0]; [0, 1]], ones(square, square));
    board(board<1) = 1;
    remainingX = round(ceil(dim(2)/(2*square)));
    remainingY = round(ceil(dim(1)/(2*square)));
   	checkerboard = repmat(board,remainingY,remainingX);
    checkerboard = checkerboard(1:dim(1),1:dim(2));
    checkerboard = checkerboard-mean(checkerboard(:));
    std_dev = std(double(checkerboard(:)));
    checkerboard = checkerboard/std_dev;
end
