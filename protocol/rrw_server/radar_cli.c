#include<radar_cli.h>
#include<rrw_proto.h>
#include<string.h>
#include<stdlib.h>
#include<stdio.h>
#include<limits.h>
#include<data_processor.h>
#include <common.h>

/**Initialize radar client*/
void rcli_init(rcli_t *cli, rdr_t *rdr,
               int cycle_dly, int cycle_dur, int meas_mode,
               int coll_sz, int meas_data_unit_sz,
               ipt_t *th_pts, int th_pts_num,
               int win_min, int win_max) {

#ifdef DBG_RCLI
  logprintf("RADAR CLIENT: initialization...\n");
#endif

  cli->rdr = rdr;

  cli->meas_no = 0;
  cli->has_unread = 0;
  cli->elapsed = 0;
  cli->last_unsucc = 0;

  pthread_mutex_init(&(cli->mtx),NULL);

  cli->meas_mode = MEAS_MODE_ON_REQ;
  cli->rcv_loop_state = RCV_ENDED;
  cli->cycle_state = CYCLE_ENDED;
  cli->cycle_dly = cycle_dly;
  cli->cycle_dur = cycle_dur;
  cli->coll_sz = coll_sz;
  cli->meas_data_unit_sz = meas_data_unit_sz;
  cli->meas_data_sz = (cli->rdr->pkt_sz/meas_data_unit_sz)*cli->coll_sz;
  cli->targets = malloc(sizeof(data_el_t)*cli->meas_data_sz);

  cli->th.points = th_pts;
  cli->th.size = th_pts_num;
  cli->win_min = win_min;
  cli->win_max = win_max;

//  rcli_rcv_loop_start(cli);
//  rcli_cycle_start(cli);
}

/**Deinitialize radar client*/
void rcli_deinit(rcli_t *cli) {
#ifdef DBG_RCLI
  logprintf("RADAR CLIENT: deinitialization...\n");
#endif
  free(cli->targets);
  pthread_mutex_destroy(&(cli->mtx));
}

/**Check if the last measurement was unsuccessful*/
int rcli_is_last_unsucc(rcli_t *cli) {
  return cli->last_unsucc;
}

/**Check if there is unread measurement data*/
int rcli_has_unread(rcli_t *cli) {
  return cli->has_unread;
}

/**Get amount of time elapsed from last measurement*/
unsigned short rcli_get_elapsed(rcli_t *cli) {
  return (unsigned short)cli->elapsed;
}

/**Get current measurement number*/
unsigned char rcli_get_meas_no(rcli_t *cli) {
  return cli->meas_no;
}

/**Increment current measurement number*/
void rcli_incr_meas_no(rcli_t *cli) {
  cli->meas_no+=1;
}

/**Cyclic measurement thread function*/
void *rcli_cycle_fn(void *arg) {
  int tmo = 0;
  struct timeval cycle_start_tm;
  double elapsed;
  rcli_t *cli = (rcli_t *)arg;

  cli->cycle_state = CYCLE_DURING;

  //memorize measurement loop start time
  gettimeofday(&cycle_start_tm,NULL);
  gettimeofday(&(cli->last_tm),NULL);

#ifdef DBG_RCLI
  logprintf("RADAR CLIENT: measurement cycle started!\n");
#endif // DBG_RCLI

  while(cli->cycle_state!=CYCLE_STOP &&
        (tmo = cli->cycle_dur==0?1:
               ((elapsed = get_elapsed_time(&cycle_start_tm)) < ((double)cli->cycle_dur*1000)))) {

printf("ELAPSED %lf DURATION %d\n",elapsed,cli->cycle_dur);
    rcli_meas(cli);

    //calculate amount of time elapsed from last measurement
    cli->elapsed = get_elapsed_time(&(cli->last_tm));
    //get time of current measurement
    gettimeofday(&(cli->last_tm),NULL);
#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: %.0lfms elapsed from last measurement\n",cli->elapsed);
#endif
//    printf("CYCLE DELAY %d\n",cli->cycle_dly);
    sleep_ms(cli->cycle_dly);
  }

#ifdef DBG_RCLI
  logprintf("RADAR CLIENT: measurement cycle ended!\n");
#endif // DBG_RCLI

  cli->elapsed = 0;
  cli->cycle_state = CYCLE_ENDED;

  /*switch to on-request mode only if cycle-mode measurement loop execution
    went beyond its time limit*/
  if(!tmo)
    rcli_en_onreq_mode(cli);

  return NULL;
}


/**Start measurement loop in cyclic mode*/
void rcli_cycle_start(rcli_t *cli) {
  rcli_rcv_loop_start(cli);
  if(cli->meas_mode == MEAS_MODE_CYCLE &&
      cli->cycle_state == CYCLE_ENDED) {

#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: starting measurement cycle...\n");
#endif // DBG_RCLI

    cli->cycle_state = CYCLE_START;
//    flog_open(get_timestamp_log_path());
    pthread_create(&(cli->cycle_meas_th),NULL,rcli_cycle_fn,(void *)cli);
    while(cli->cycle_state!=CYCLE_DURING)
      Sleep(1);
  }
}

/*Stop measurement loop in cyclic mode*/
void rcli_cycle_stop(rcli_t *cli) {
  rcli_rcv_loop_stop(cli);
  if(cli->meas_mode == MEAS_MODE_CYCLE &&
      cli->cycle_state == CYCLE_DURING) {

#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: stopping measurement cycle\n");
#endif // DBG_RCLI

    cli->cycle_state = CYCLE_STOP;

    while(cli->cycle_state!=CYCLE_ENDED) {
      printf("STOPPING!\n");
      Sleep(1);
    }
//    flog_close();
  }
}

void *rcli_rcv_loop_fn(void *arg) {
  rcli_t *cli = (rcli_t *)arg;
  int rv;

  while(cli->rcv_loop_state!=RCV_STOP) {
    pthread_mutex_lock(&(cli->mtx));
      cli->last_unsucc = ((rv = rdr_collect_pkts(cli->rdr,&(cli->data),
                            cli->coll_sz,(void *)cli))!=0);
//    printf("COLLECT! %d\n",rv);
    memset(cli->targets,0,sizeof(data_el_t)*cli->meas_data_sz);
    if(cli->last_unsucc == 0) {
      process_data(&(cli->data_proc));
//      printf("PROCESS! %d\n",rv);
    }

    pthread_mutex_unlock(&(cli->mtx));
    Sleep(10);
  }
  cli->rcv_loop_state = RCV_ENDED;

  return NULL;
}

void rcli_rcv_loop_start(rcli_t *cli) {
  if(cli->rcv_loop_state==RCV_ENDED) {
    cli->rcv_loop_state = RCV_START;
    pthread_create(&(cli->rcv_loop_th),NULL,rcli_rcv_loop_fn,(void *)cli);
  }
}

void rcli_rcv_loop_stop(rcli_t *cli) {
  if(cli->rcv_loop_state!=RCV_ENDED) {
    cli->rcv_loop_state = RCV_STOP;
    while(cli->rcv_loop_state!=RCV_ENDED);
  }
}


/**Enable on-request measurement mode*/
void rcli_en_onreq_mode(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_CYCLE && cli->cycle_state!=CYCLE_ENDED)
    rcli_cycle_stop(cli);

#ifdef DBG_RCLI
  logprintf("RADAR CLIENT: enabling on-request measurement mode!\n");
#endif // DBG_RCLI

  cli->meas_mode = MEAS_MODE_ON_REQ;
  cli->has_unread = 0;
}

/**Enable cyclic measurement mode*/
void rcli_en_cycle_mode(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_ON_REQ) {
    cli->meas_mode = MEAS_MODE_CYCLE;

#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: enabling cyclic measurement mode!\n");
#endif // DBG_RCLI

    rcli_cycle_start(cli);
  }
}

/**Set cyclic measurement total duration*/
void rcli_set_cycle_dur(rcli_t *cli, unsigned short dur) {
  cli->cycle_dur = reverse_us(dur);
}

/**Set value of delay after each iteration in cyclic measurement mode*/
void rcli_set_cycle_dly(rcli_t *cli, unsigned short  dly) {
  cli->cycle_dly = dly;
//  cli->cycle_dly = ntohs(dly);
}

/**Measure targets data*/
int rcli_meas(rcli_t *cli) {

  pthread_mutex_lock(&(cli->mtx));
  cli->has_data = 0;

  //collect packets
  if(!cli->last_unsucc) {
#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: packets collecting succeded!\n");
#endif
    //TODO: apply processing and estimation routines

    //FILLER ->
//  memset(cli->targets,0,sizeof(data_el_t)*cli->meas_data_sz);
//  write_to_rrw_points(cli->targets,&(cli->data.sweeps),cli->meas_data_sz,
//                      cli->win_min, cli->win_max,&(cli->th),
//                      cli->cycle_dly/2, cli->v_avg);
    /*if collecting succeded mark last measurement as successful
      and indicate presence of unread data*/
    cli->has_unread = 1;
    cli->last_unsucc = 0;
  cli->has_data = 1;
  } else {
#ifdef DBG_RCLI
    logprintf("RADAR CLIENT: packets collecting failed!\n");
#endif
  }

  pthread_mutex_unlock(&(cli->mtx));

  return 0;
}

/**Copy last targets data to user buffer*/
void rcli_copy_last(rcli_t *cli, char *buf) {
  pthread_mutex_lock(&(cli->mtx));
  memcpy(buf,cli->targets,sizeof(data_el_t)*cli->meas_data_sz);
  cli->has_unread = 0;
  pthread_mutex_unlock(&(cli->mtx));
}

void rcli_copy_last_raw(rcli_t *cli, raw_pt_t *rbuf, raw_pt_t *fbuf) {
  double v;
  int i;
  pthread_mutex_lock(&(cli->mtx));

  for(i=0; i<1024; i++){
    v = dbm(cli->data.sweeps.rise[i],i);
    rbuf[i].status = pow_status(v);
    rbuf[i].power = reverse_i(i);

    v = dbm(cli->data.sweeps.fall[i], i);
    fbuf[i].status = pow_status(v);
    fbuf[i].power = reverse_i(i);
  }
  cli->has_unread = 0;
  pthread_mutex_unlock(&(cli->mtx));
}

/**Get current measurement mode: may be MEAS_MODE_CYCLE or MEAS_MODE_ON_REQ)*/
int rcli_meas_mode(rcli_t *cli) {
  return cli->meas_mode;
}

/**Extract sweep direction mark from packet's header*/
static char sweep_dir(char *pkt) {
  return (unsigned char)pkt[0] & 0x0F;
}

/**Extract ordinal number from packet's header */
static char pkt_no(char *pkt) {
  return (unsigned char)pkt[0] >> 4;
}

static int extr_exp(char *pkt) {
  int exp_val;
  unsigned short *us_pkt = (unsigned short *)pkt;
  exp_val = (us_pkt[0] >> 8)-243;
  return exp_val;
}

/**Packet collecting callback for radar object*/
int rcli_collect(rdr_t *rdr, void *coll, int coll_sz, void *arg) {
  int zero_counter = 0;
  rcli_t *rcli = (rcli_t *)arg;
  int i,j,o;
  int cur_pkt,next_pkt,next_dir,cur_dir;
  int rv;
  char dirs[2] = {DIR_RISE, DIR_FALL};
  unsigned short *data;
  int exp_val;
  int pkt_data_size = (rdr->pkt_sz-rcli->meas_data_unit_sz)/rcli->meas_data_unit_sz;
  rrw_data2_t *sweeps = (rrw_data2_t *)coll;

  //for each sweep direction
  for(i=0; i<2; i+=1) {
    next_pkt = 0;
    next_dir = dirs[i];
    o = 0;
    //recieve 4 packets in order of packet no. from 0 to 3
    do {
      rv = rdr_recv_pkt(rdr);
      if(rv<=0)
        return 1;

      cur_pkt = pkt_no(rdr_get_pkt(rdr));
      cur_dir = sweep_dir(rdr_get_pkt(rdr));

#ifdef DBG_RDR
      logprintf("RADAR: number %d\n",cur_pkt);
      logprintf("RADAR: sweep direction %x, %s\n",cur_dir,cur_dir==DIR_RISE?"RISE":"FALL");
#endif
      if(cur_pkt!=next_pkt || cur_dir!=next_dir) {

#ifdef DBG_RDR
        if(cur_pkt!=next_pkt)
          logprintf("RADAR: packet number is incorrect!\n");
        if(cur_dir!=next_dir)
          logprintf("RADAR: sweep direction is incorrect!\n");
#endif

        continue;
      }

      exp_val = extr_exp(rdr_get_pkt(rdr));
      data = ((unsigned short *)rdr_get_pkt(rdr))+1;
      for(j=0; j<pkt_data_size; j+=1) {
        sweeps->data[i][j+o] = data[j] << 5;
        sweeps->data[i][j+o] >>= exp_val;
        zero_counter+=(sweeps->data[i][j+o]==0);
//        sweeps->data[i][j+o] <<= 3; //just for normalization, not necessery
      }
      if(zero_counter>=pkt_data_size-1)
        printf("RADAR PACKET %d IS NULL!\n",cur_pkt);

      next_pkt+=1;
      o+=pkt_data_size;
    } while(next_pkt!=coll_sz);
  }

  return 0;
}
