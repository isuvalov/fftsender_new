#include <common.h>
#include <stdio.h>
#include <stdlib.h>

#include <rrw_server.h>
#include <radar_cli.h>
#include <cfg.h>
#include <debuglog.h>
#include <data_processor.h>

srv_t srv;
rcli_t cli;
rdr_t rdr;
cfg_t cfg;

void exit_cb(void){
  srv_close(&srv);
  data_proc_deinit(&cli.data_proc);
  rcli_deinit(&cli);
  rdr_disconn(&rdr);
  rdr_deinit(&rdr);
  cfg_unload(&cfg);
  eudp_finish();
}

int main(int argc, char *argv[]) {

  if(cfg_load(&cfg,"rrw_server.cfg")!=0)
    return -1;

  eudp_start();

  rdr_init(&rdr,
           cfg.radar_cli_addr,cfg.radar_cli_port,cfg.radar_rcv_timeout,
           cfg.radar_pkt_size,rcli_collect);
  rdr_conn(&rdr);
  rcli_init(&cli,&rdr,
            100,
            //cfg.meas_cycle_iter_delay,
            cfg.meas_cycle_dur,cfg.meas_mode,
            cfg.data_coll_size, cfg.data_unit_size,
            cfg.threshold_polyline,cfg.threshold_pts_num,
            cfg.window_min,cfg.window_max);


  srv_init(&srv,cfg.server_addr,cfg.server_port,
           cfg.server_rcv_timeout,cfg.server_snd_timeout,&cli);
  srv_open(&srv);

  data_proc_init(&cli.data_proc,
                 cfg.do_restore_gaps,cfg.do_recalc_dist,
                 cfg.do_check_spd, cfg.do_avg_spd,
                 cfg.do_check_dist,
                 cfg.max_fails_num, cfg.avg_spds_num,
                 &(cli.data.sweeps),cfg.window_min,cfg.window_max,
                 &(cli.th),cli.targets,1024);

  atexit(exit_cb);
  srv_start(&srv);


    return 0;
}
