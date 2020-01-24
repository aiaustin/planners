comment 'house 1 - Task Formalism for NonLin.
         12-Oct-83, Austin Tate';

actschema build
  pattern {build house}
  expansion 1 action {excavate, pour footers       }
            2 action {pour concrete foundations    }
            3 action {erect frame and roof         }
            4 action {lay brickwork                }
            5 action {finish roofing and flashing  }
            6 action {fasten gutters and downspouts}
            7 action {finish grading               }
            8 action {pour walks, landscape        }
            9 action {install services             }
           10 action {decorate                     }
  orderings sequence 1 to 8
  conditions   supervised {footers poured        } at 2 from 1
               supervised {foundations laid      } at 3 from 2
               supervised {frame and roof erected} at 4 from 3
               supervised {brickwork done        } at 5 from 4
               supervised {roofing finished      } at 6 from 5
               supervised {gutters etc fastened  } at 7 from 6
             unsupervised {storm drains laid     } at 7
               supervised {grading done          } at 8 from 7
end;
  
actschema service
  pattern {install services}
  expansion 1 action {install drains           }
            2 action {lay storm drains         }
            3 action {install rough plumbing   }
            4 action {install finished plumbing}
            5 action {install rough wiring     }
            6 action {finish electrical work   }
            7 action {install kitchen equipment}
            8 action {install air conditioning }
  orderings 1 ---> 3   3 ---> 4   5 ---> 6   3 ---> 7   5 ---> 7
  conditions   supervised {drains installed        } at 3 from 1
               supervised {rough plumbing installed} at 4 from 3
               supervised {rough wiring installed  } at 6 from 5
               supervised {rough plumbing installed} at 7 from 3
               supervised {rough wiring installed  } at 7 from 5
             unsupervised {foundations laid        } at 1
             unsupervised {foundations laid        } at 2
             unsupervised {frame and roof erected  } at 5
             unsupervised {frame and roof erected  } at 8
             unsupervised {basement floor laid     } at 8
             unsupervised {flooring finished       } at 4
             unsupervised {flooring finished       } at 7
             unsupervised {painted                 } at 6
end;
           
actschema decor
  pattern {decorate}
  expansion 1 action {fasten plaster and plaster board}
            2 action {pour basement floor             }
            3 action {lay finished flooring           }
            4 action {finish carpentry                }
            5 action {sand and varnish floors         }
            6 action {paint                           }
  orderings sequence 2 to 5   1 ---> 3   6 ---> 5
  conditions unsupervised {rough plumbing installed   } at 1
             unsupervised {rough wiring installed     } at 1
             unsupervised {air conditioning installed } at 1
             unsupervised {drains installed           } at 2
             unsupervised {plumbing finished          } at 6
             unsupervised {kitchen equipment installed} at 6
               supervised {plastering finished        } at 3 from 1
               supervised {basement floor laid        } at 3 from 2
               supervised {flooring finished          } at 4 from 3
               supervised {carpentry finished         } at 5 from 4
               supervised {painted                    } at 5 from 6
end;

primitive
 {excavate, pour footers          }  with effect + {footers poured            }
 {pour concrete foundations       }  with effect + {foundations laid          }
 {erect frame and roof            }  with effect + {frame and roof erected    }
 {lay brickwork                   }  with effect + {brickwork done            }
 {finish roofing and flashing     }  with effect + {roofing finished          }
 {fasten gutters and downspouts   }  with effect + {gutters etc fastened      }
 {finish grading                  }  with effect + {grading done              }
 {pour walks, landscape           }  with effect + {landscaping done          }
 {install drains                  }  with effect + {drains installed          }
 {lay storm drains                }  with effect + {storm drains laid         }
 {install rough plumbing          }  with effect + {rough plumbing installed  }
 {install finished plumbing       }  with effect + {plumbing finished         }
 {install rough wiring            }  with effect + {rough wiring installed    }
 {finish electrical work          }  with effect + {electrical work finished  }
 {install kitchen equipment       }  with effect + {kitchen equipment installed}
 {install air conditioning        }  with effect + {air conditioning installed}
 {fasten plaster and plaster board}  with effect + {plastering finished       }
 {pour basement floor             }  with effect + {basement floor laid       }
 {lay finished flooring           }  with effect + {flooring finished         }
 {finish carpentry                }  with effect + {carpentry finished        }
 {sand and varnish floors         }  with effect + {floors finished           }
 {paint                           }  with effect + {painted                   }
;

'[house1 TF] ready'.pr; 1.nl;
