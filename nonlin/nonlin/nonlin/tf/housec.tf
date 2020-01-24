comment '12-Oct-83 House Building example with costs - HouseC for Nonlin
         simple house building task from Weist and Levy 1969';

primitive
  {excavate, pour footers}
       with effect + {footers poured}  :4
  {pour concrete foundations}
       with effect + {foundations laid}  :2
  {erect frame and roof}
       with effect + {frame and roof erected}  :4
  {lay brickwork}
       with effect + {brickwork done}  :6
  {finish roofing and flashing}
       with effect + {roofing finished}  :2
  {fasten gutters and downspouts}
       with effect + {gutters etc fastened}  :1
  {finish grading}
       with effect + {grading done}  :2
  {pour walks, landscape}
       with effect + {landscaping done}  :5
  {install drains}
       with effect + {drains installed}  :1
  {lay storm drains}
       with effect + {storm drains laid}  :1
  {install rough plumbing}
       with effect + {rough plumbing installed}  :3
  {install finished plumbing}
       with effect + {plumbing finished}  :2
  {install rough wiring}
       with effect + {rough wiring installed}  :2
  {finish electrical work}
       with effect + {electrical work finished}  :1
  {install kitchen equipment}
       with effect + {kitchen equipment installed}  :1
  {install air conditioning}
       with effect + {air conditioning installed}  :4
  {fasten plaster and plaster board}
       with effect + {plastering finished}  :10
  {pour basement floor}
       with effect + {basement floor laid}  :2
  {lay finished flooring}
       with effect + {flooring finished}  :3
  {finish carpentry}
       with effect + {carpentry finished}  :3
  {sand and varnish floors}
       with effect + {floors varnished}  :2
  {paint}
       with effect + {painted}  :3
;

actschema build
  pattern {build house}
  expansion 1 action {excavate, pour footers}
            2 action {pour concrete foundations}
            3 action {erect frame and roof}
            4 action {lay brickwork}
            5 action {finish roofing and flashing}
            6 action {fasten gutters and downspouts}
            7 action {finish grading}
            8 action {pour walks, landscape}
            9 action {install services}:21
           10 action {decorate}:14
  orderings sequence 1 to 8
  conditions supervised {footers poured} at 2 from 1
             supervised {foundations laid} at 3 from 2
             supervised {frame and roof erected} at 4 from 3
             supervised {brickwork done} at 5 from 4
             supervised {roofing finished} at 6 from 5
             supervised {gutters etc fastened} at 7 from 6
             unsupervised {storm drains laid} at 7
             supervised {grading done} at 8 from 7
end;

actschema service
  pattern {install services}
  expansion 1 action {install drains}
            2 action {lay storm drains}
            3 action {install rough plumbing}
            4 action {install finished plumbing}
            5 action {install rough wiring}
            6 action {finish electrical work}
            7 action {install kitchen equipment}
            8 action {install air conditioning}
  orderings 1 ---> 3   3 ---> 4   5 ---> 6   3 ---> 7   5 ---> 7
  conditions supervised {drains installed} at 3 from 1
             supervised {rough plumbing installed} at 4 from 3
             supervised {rough wiring installed} at 6 from 5
             supervised {rough plumbing installed} at 7 from 3
             supervised {rough wiring installed} at 7 from 5
             unsupervised {foundations laid} at 1
             unsupervised {foundations laid} at 2
             unsupervised {frame and roof erected} at 5
             unsupervised {frame and roof erected} at 8
             unsupervised {basement floor laid} at 8
             unsupervised {flooring finished} at 4
             unsupervised {flooring finished} at 7
             unsupervised {painted} at 6
end;

actschema decor
  pattern {decorate}
  expansion 1 action {fasten plaster and plaster board}
            2 action {pour basement floor}
            3 action {lay finished flooring}
            4 action {finish carpentry}
            5 action {sand and varnish floors}
            6 action {paint}
  orderings sequence 2 to 5   1 ---> 3   6 ---> 5
  conditions unsupervised {rough plumbing installed} at 1
             unsupervised {rough wiring installed} at 1
             unsupervised {air conditioning installed} at 1
             unsupervised {drains installed} at 2
             unsupervised {plumbing finished} at 6
             unsupervised {kitchen equipment installed} at 6
             supervised {plastering finished} at 3 from 1
             supervised {basement floor laid} at 3 from 2
             supervised {flooring finished} at 4 from 3
             supervised {carpentry finished} at 5 from 4
             supervised {painted} at 5 from 6
end;

'[housec TF] ready'.pr; 1.nl;
