classdef MDBTimeSeries
    properties (SetAccess = public)
        Type
        Time
        VarNames    
        Table
    end
     
     methods
         function o = MDBTimeSeries(Time,VarNames,Table)
             %o.DBConnection = oSubject.DBConnection;
             o.Type = 'TimeSeries'; 
             o.Time = Time; 
             o.VarNames = VarNames;
             o.Table = Table; 

         end
     end
end