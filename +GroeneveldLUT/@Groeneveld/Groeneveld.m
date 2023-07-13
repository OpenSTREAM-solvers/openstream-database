classdef Groeneveld < Dataset

   properties
       entryID
   end

   methods
       
        function preprocessor(obj)
        %PREPROCESSOR Prepares dataset for further processing
        %   Detailed explanation goes here
        end
        function makeInputFiles(obj)
        %MAKEINPUTFILES Creates input files on-demand
        end

        function listEntries(obj)
        %LISTENTRIES Lists all the possible entries

        end
        
        function validateEntry(obj, entryID)
        %VALIDATEENTRY Check if an entryID is valid
        %   Throws error if entryID is invalid

        end


   end


end