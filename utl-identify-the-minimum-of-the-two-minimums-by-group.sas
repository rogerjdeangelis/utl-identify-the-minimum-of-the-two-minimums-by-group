Identify the minimum of the two minimums by group

THREE SOLUTIONS

     1. Proc transpose then summary
     2. Means, arrays and datastep
     3. Single datastep (preferred?)


github
https://tinyurl.com/ycrg2glt
https://github.com/rogerjdeangelis/utl-identify-the-minimum-of-the-two-minimums-by-group

SAS Forum
https://tinyurl.com/ycom7q9n
https://communities.sas.com/t5/SAS-Programming/Select-the-least-value-in-the-repeated-measurements-while/m-p/505211

Interesting solutions by

Mike Keintz
https://communities.sas.com/t5/user/viewprofilepage/user-id/31461
and
Novinosrin
https://communities.sas.com/t5/user/viewprofilepage/user-id/138205


INPUT
=====

 WORK.HAVE total obs=20     +    RULES
                            |
         proc_              |
   id    range    dx_range  |
                            |
    1      12         9     |
    1       8        12     |
    1       6         8     |
    1       6         8     |
    1       5        14     |
    1       5        11     |
    1       5         8     |
    1       5         .     |
    1       5        13     |    Min proc range=5 Min dx_range=8
                            |    Min of min =5
                            |
                            |    min of min=5  fro='proc_range'
    2       7         0     |
    2       8         0     |
    2      14         0     |
    2      13         0     |
    2      11         0     |    min proc range=7 min dx_range=0
                            |    min of min =0
                            |
    3       8         7     |    min of min=0  fro='dx_range'
    3       0         .     |
    3       7         7     |
    4       1         5     |
    4       1         .     |
    4       1         7     |    min proc range=1 min dx_range=5
                            |    min of min =1 fro='proc range'

EXAMPLE OUTPUT
--------------

 WORK.WANT total obs=4

         min_
  id    of_min      minVar

   1       5      proc_range
   2       0      dx_range
   3       0      proc_range
   4       1      proc_range



PROCESS
=======

  1. Proc transpose then summary

     proc transpose data=have out=havxpo(where=(min_of_min ne .)
         keep=id _name_ col1 rename=(_name_=var col1=min_of_min));
        by _all_  notsorted;
        var proc_range dx_range;
     run;quit;

     proc summary data=havXpo min nway idmin;
     class id;
     var min_of_min;
     output out=want (drop=_:) min= minid(min_of_min(var))=minVar;
     run;quit;

  2. Means, arrays and datastep

     PROC MEANS DATA=have NOPRINT NWAY;
     CLASS id;
     VAR proc_range--dx_range;
     OUTPUT OUT=temp(drop=_:) min=;
     RUN;

     data want;
     set temp;
     array t(*) proc_range--dx_range;
     length source $20;
     min=min(of t(*));
     if range(of t(*))=0 then source='BOTH';
     else do;
     _t=whichn(min,of t(*));
     if _t>0 then source=vname(t(_t));
     end;
     keep id min source ;
     run;

  3. Single DOW loop

     data want (keep=id min source);
       set have;
       by id;
       array mins {2} _temporary_;
       if first.id then call missing(of mins{*});

       array src {2} $5 _temporary_ ('proc','dx');
       array vals {2} proc_range dx_range;
       do i=1 to 2;
         mins{i}=min(mins{i},vals{i});
       end;
       if last.id;
       min=min(of mins{*});
       if mins{1}=mins{2} then source='both';
       else source=src{whichn(min,of mins{*})};
     run;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
input id proc_range dx_range;
cards4;
1 12 9
1 8 12
1 6 8
1 6 8
1 5 14
1 5 11
1 5 8
1 5 .
1 5 13
2 7 0
2 8 0
2 14 0
2 13 0
2 11 0
3 8 7
3 0 .
3 7 7
4 1 5
4 1 .
4 1 7
;;;;
run;quit;

