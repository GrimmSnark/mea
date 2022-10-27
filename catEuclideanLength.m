function l = catEuclideanLength(catRow, catCol)

l = 0;
for i = 2 : length(catRow)
   
    l = l + sqrt((catRow(i) - catRow(i - 1))^2 + (catCol(i) - catCol(i - 1))^2);
end

end