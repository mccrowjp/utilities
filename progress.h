using namespace std;

#include <iostream>
#include <ctime>

class progressbar {
 protected:
  time_t starttime;
  int estimate_sec;
  int full;
  int progress;
  int lastdraw_progress;
 public:
  progressbar(void);
  ~progressbar(void);
  progressbar(int totalsteps);
  void reset(int totalsteps);
  void update(int completedsteps);
  void draw(void);
  void erase(void);
};

progressbar::progressbar(int totalsteps) {
  reset(totalsteps);
}

progressbar::~progressbar() {
  erase();
}

void progressbar::reset(int totalsteps) {
  starttime = time(NULL);
  full = totalsteps;
  progress = 0;
  lastdraw_progress = 0;
  estimate_sec = -1;
  this->draw();
}

void progressbar::update(int completedsteps) {
  time_t curtime = time(NULL);

  progress = completedsteps;

  if(progress > full)
    progress = full;

  if(progress > 0) {
    if(full == progress) // total time taken
        estimate_sec = int(curtime - starttime);
    else                 // estimated time remaining
        estimate_sec = int(curtime - starttime) * ((full-progress) / progress);

    this->draw();
}

void progressbar::erase(void) {
  cerr<<"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
  cerr<<"                                                                               ";
  cerr<<"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
}

void progressbar::draw(void) {
  double per = 0.1*int((1.0*progress/full)*1000.0);
  int pnum = int(per / 5);
  int i;

  lastdraw_progress = progress;
  
  cerr<<"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";

  cerr<<"[";
  for(i=0;i<pnum;i++) {
    cerr<<"*";
  }
  for(i=0;i<20-pnum;i++) {
    cerr<<".";
  }
  cerr<<"] "<<progress<<"/"<<full<<" "<<per;
  if(int(10*per) % 10 == 0) cerr<<".0";
  cerr<<"% ";

  if(estimate_sec > 0) {
    if(estimate_sec > 7200) {
      cerr<<int(estimate_sec/3600)<<"hr.";
    } else if(estimate_sec > 120) {
      cerr<<int(estimate_sec/60)<<"min.";
    } else {
      cerr<<int(estimate_sec)<<"sec.";
    }
  }
  cerr<<"    ";
  cerr.flush();
}
