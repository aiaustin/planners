;;; A simple house-building domain with resources
;;; Author: Jeff Dalton

;;; Created: June 1993
;;; Updated: Thu Feb 23 10:07:32 1995

;;; Additional Task:
;;;
;;;   better_build_secure_house
;;;     Like build_secure_house, but uses a more (search-) efficient builder.

task better_build_secure_house;
  nodes 1 start,  
        2 finish,
        3 action {build secure house};
  orderings 1 ---> 3,
            3 ---> 2;
  resources consumes {resource money} = 0 .. 2000 pounds overall;
end_task;

