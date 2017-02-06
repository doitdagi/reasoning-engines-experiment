% given a cvs file of a three column dataset(KD-tree, jREC and interval tree)
% of experiment results, this function plots a graph of the the mean and
% standard deviation of the results
function [intervaltreeAry, jrecAry] = PlotExperimentResult(filePath, title)
 INTERVAL_TREE = 'inttree';
 JREC = 'jrec';

 % Open text file  
 fid = fopen(filePath,'r');
 % Read the data from the file into cell array
 % Ignore number of alerts as it is constant all the time --using *
 % we get three 1 X 3600 cell arrays
 rawExperimentData = textscan(fid, '%s %d64 %*d32 %d32', 'Delimiter',';');
 fclose(fid);

 % Splitup the raw data into three separate arrays 
 reasoners = rawExperimentData{1};
 executionTime = rawExperimentData{2};
 events = rawExperimentData{3};
 
 %Calculate no of unique in the experiment, and the no of repeation for a single event 
 noOfUniqueEvents = size(unique(events),1);
 noOfEventRepeation = size(events, 1)/(noOfUniqueEvents*3);

 %build an empty array of #size_of_experiment_data / no_of_reasoner X 2, where the two columns are no of non-unique events and
 %execution time respectively
 totalEvents = noOfUniqueEvents * noOfEventRepeation; 
 rawIntervalTreeAry = zeros(totalEvents, 2);
 rawJRecAry = zeros(totalEvents, 2);


 % Fill the arrays from events and executionTime arrays 
 intervalTreeCounter = 0;
 jrecCounter = 0;
 
 for n =1 : size(reasoners, 1)
   if strcmp(reasoners(n, 1), INTERVAL_TREE)
        intervalTreeCounter = intervalTreeCounter +1;
        rawIntervalTreeAry(intervalTreeCounter, 1) = events(n,1);
        rawIntervalTreeAry(intervalTreeCounter, 2) = executionTime(n, 1);
    elseif strcmp(reasoners(n, 1), JREC)
        jrecCounter = jrecCounter +1;
        rawJRecAry(jrecCounter, 1) = events(n,1);
        rawJRecAry(jrecCounter, 2) = executionTime(n, 1);
    end
 end        

 format shortG;
 
 % Prepare the final array, by storing only the mean and standard deviation 
 % of non-unique no of events
 intervaltreeAry = zeros(noOfUniqueEvents, 3);
 jrecAry = zeros(noOfUniqueEvents, 3);
 
 for m = 1:noOfUniqueEvents
     x = ((m*noOfEventRepeation)-noOfEventRepeation)+1;
   
     intervaltreeAry(m,1) = rawIntervalTreeAry(m*noOfEventRepeation,1);
     intervaltreeAry(m,2) = mean(rawIntervalTreeAry(x:m*noOfEventRepeation,2));
     intervaltreeAry(m,3) = std(rawIntervalTreeAry(x:m*noOfEventRepeation,2));
     
     jrecAry(m,1) = rawJRecAry(m*noOfEventRepeation,1);
     jrecAry(m,2) = mean(rawJRecAry(x:m*noOfEventRepeation,2));
     jrecAry(m,3) = std(rawJRecAry(x:m*noOfEventRepeation,2));
 end


 % sort matrix based on the first column (no of events)
 jrecAry = sortrows(jrecAry, 1);
 intervaltreeAry = sortrows(intervaltreeAry, 1);
 
 %Plot the graph
 Jx = jrecAry(:,1);
 Jy =  jrecAry(:,2);
 Jerr = jrecAry(:,3);

 INTx = intervaltreeAry(:,1);
 INTy = intervaltreeAry(:,2);
 INTerr = intervaltreeAry(:,3);
figure;

axis manual;

%hold on;
errorbar(Jx,Jy,Jerr);
hold on;
errorbar(INTx, INTy, INTerr);

xlabel('Number of events');
xticks([10, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]);

ylabel('Execution time [ms]');
ax = gca;
ax.YAxis.Exponent = 3;

legend('jRec','Interval Tree','Location', 'northwest');
print('-bestfit','BestFitFigure','-dpdf')
end

