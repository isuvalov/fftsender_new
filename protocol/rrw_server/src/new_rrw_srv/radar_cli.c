#include<radar_cli.h>
#include<rrw_proto.h>
#include<string.h>
#include<stdlib.h>
#include<stdio.h>
#include<limits.h>
#include<data_processor.h>

void rcli_init(rcli_t *cli, rdr_t *rdr) {
  cli->rdr = rdr;

  cli->meas_no = 0;
  cli->has_unread = 0;
  cli->elapsed = 0;
  cli->last_unsucc = 0;
  
  cli->targets = malloc(sizeof(data_el_t)*MEAS_DATA_SIZE);

  pthread_mutex_init(&(cli->mtx),NULL);

  cli->meas_mode = MEAS_MODE_CYCLE;
  cli->cycle_state = CYCLE_ENDED;
  cli->cycle_dly = 200;
  cli->cycle_dur = 3600;
  
  rcli_cycle_start(cli);

}

void rcli_deinit(rcli_t *cli) {
  free(cli->targets);
  pthread_mutex_destroy(&(cli->mtx));
}

int rcli_is_last_unsucc(rcli_t *cli) {
  return cli->last_unsucc;
}

int rcli_has_unread(rcli_t *cli) {
  return cli->has_unread;
}

unsigned short rcli_get_elapsed(rcli_t *cli) {
  return (unsigned short)cli->elapsed;
}

unsigned char rcli_get_meas_no(rcli_t *cli) {
  return cli->meas_no;
}

void rcli_incr_meas_no(rcli_t *cli) {
  cli->meas_no+=1;
}

void *rcli_cycle_fn(void *arg) {
  int tmo = 0;
  struct timeval cycle_start_tm;
  rcli_t *cli = (rcli_t *)arg;
  
  cli->cycle_state = CYCLE_DURING;
  
  gettimeofday(&cycle_start_tm,NULL);
  gettimeofday(&(cli->last_tm),NULL);

  printf("CYCLE STARTED\n");

  while(cli->cycle_state!=CYCLE_STOP &&
	(tmo = (get_elapsed_time(&cycle_start_tm) < ((double)cli->cycle_dur*1000)))) {

    rcli_meas(cli);
    cli->elapsed = get_elapsed_time(&(cli->last_tm));
    gettimeofday(&(cli->last_tm),NULL);
    
    sleep_ms(cli->cycle_dly);
    /* printf("ELAPSED %lf\n",cli->elapsed); */
  }
  
  printf("CYCLE ENDED\n");
  cli->elapsed = 0;
  cli->cycle_state = CYCLE_ENDED;
  if(!tmo)
    rcli_en_onreq_mode(cli);
  
  return NULL;
} 

void rcli_cycle_start(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_CYCLE &&
     cli->cycle_state == CYCLE_ENDED) {
    printf("STARTING CYCLE...\n");
    cli->cycle_state = CYCLE_START;
    pthread_create(&(cli->cycle_meas_th),NULL,rcli_cycle_fn,(void *)cli);

    while(cli->cycle_state!=CYCLE_DURING);
  }
}

void rcli_cycle_stop(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_CYCLE &&
     cli->cycle_state == CYCLE_DURING) {
    printf("STOPPING CYCLE...\n");

    cli->cycle_state = CYCLE_STOP;

    while(cli->cycle_state!=CYCLE_ENDED);
  }
}

void rcli_en_onreq_mode(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_CYCLE && cli->cycle_state!=CYCLE_ENDED)
    rcli_cycle_stop(cli);
  cli->meas_mode = MEAS_MODE_ON_REQ;
  cli->has_unread = 0;
}

void rcli_en_cycle_mode(rcli_t *cli) {
  if(cli->meas_mode == MEAS_MODE_ON_REQ) {
    cli->meas_mode = MEAS_MODE_CYCLE;
    rcli_cycle_start(cli);
  }
}

void rcli_set_cycle_dur(rcli_t *cli, unsigned short dur) {
  cli->cycle_dur = dur;
}

void rcli_set_cycle_dly(rcli_t *cli, unsigned short  dly) {
  cli->cycle_dly = dly;
}

void rcli_meas(rcli_t *cli) {
  int i;
  //recieve, (by radar reciever),
  //process, estimate (by processing routines)
  //and represent in terms of protocol (by radar client)

  pthread_mutex_lock(&(cli->mtx));

  //FILLER

  rdr_collect_pkts(cli->rdr,&(cli->data),4,256);

  for(i=0; i<MEAS_DATA_SIZE; i+=1) {
    cli->targets[i].pwr = (cli->data.sweeps.sw1[i]);
  }

  cli->has_unread = 1;

  //set last unsucc flag if couldn't recieve data from radar
  
  pthread_mutex_unlock(&(cli->mtx));
}

void rcli_copy_last(rcli_t *cli, char *buf) {
  pthread_mutex_lock(&(cli->mtx));
  memcpy(buf,cli->targets,sizeof(data_el_t)*MEAS_DATA_SIZE);
  cli->has_unread = 0;
  pthread_mutex_unlock(&(cli->mtx));
}

int rcli_meas_mode(rcli_t *cli) {  
  return cli->meas_mode;
}

//DATA COLLECTING

static char sweep_dir(char *pkt) {
  return (unsigned char)pkt[0] & 0x0F;
}

static char pkt_no(char *pkt) {
  return (unsigned char)pkt[0] >> 4;
}

int rcli_collect(rdr_t *rdr, void *coll, int coll_sz, int pkt_data_size) {
  int i,j,k,o;
  int cur_pkt,next_pkt,next_dir,cur_dir;
  int rv;
  int both_sweeps = 0;
  char dirs[2] = {0xF,0xC};
  unsigned short *data;
  rrw_data2_t *sweeps = (rrw_data2_t *)coll;

  for(i=0; i<2; i+=1) {
    next_pkt = 0;
    next_dir = dirs[i];
    o = 0;
    do {
      rdr_recv_pkt(rdr);
      cur_pkt = pkt_no(rdr_get_pkt(rdr));
      cur_dir = sweep_dir(rdr_get_pkt(rdr));

      if(cur_pkt!=next_pkt || cur_dir!=next_dir)
	continue;

      data = (unsigned short *)(rdr_get_pkt(rdr) + 2);
      memcpy(sweeps->data[i]+o,data,sizeof(unsigned short)*pkt_data_size);

      /* for(k=0,j=o; k<pkt_data_size; k+=1,j+=1) { */
      /* 	printf("%hu\n",sweeps->data[i][j]); */
      /* } */
      /* printf("PKT %d DIR %x, %d\n",cur_pkt,cur_dir,rand()); */

      next_pkt+=1;
      o+=pkt_data_size;
    } while(next_pkt!=coll_sz);
  }

  return 0;
}
