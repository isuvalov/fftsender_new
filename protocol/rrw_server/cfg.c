#include<common.h>
#include<cfg.h>
#include<stdlib.h>

int cfg_wr(cfg_t *cfg, char *id, int type, void *val) {
  config_t *hnd = &(cfg->hnd);
  config_setting_t *s,*se;
  int i;
  int rv = 0;


  config_write_file(hnd,cfg->fname);

  return rv;
}

int cfg_read(cfg_t *cfg, char *id, int type, void *val) {
  config_t *hnd = &(cfg->hnd);
  config_setting_t *s,*se;
  int i;
  int rv = CONFIG_FALSE;

  if(config_lookup(hnd,id)==NULL) {
    return -1;
  }
  switch(type) {
    case CFG_INT:
      rv = config_lookup_int(hnd,id,(int *)val);
      #ifdef DBG_CFG
      if(rv==CONFIG_TRUE) {
        printf("CONFIG: setting \"%s\" = %d\n",id,*(int *)val);
      }
      #endif
      break;

    case CFG_STR:
      rv = config_lookup_string(hnd,id,(const char **)val);
      #ifdef DBG_CFG
      if(rv==CONFIG_TRUE) {
        printf("CONFIG: setting \"%s\" = %s\n",id,*(char **)val);
      }
      #endif
      break;

    case CFG_FLOAT:
      rv = config_lookup_float(hnd,id,(double *)val);
      #ifdef DBG_CFG
      if(rv==CONFIG_TRUE) {
        printf("CONFIG: setting \"%s\" = %lf\n",id,*(double *)val);
      }
      #endif
      break;

    case CFG_BOOL:
      rv = config_lookup_bool(hnd,id,(int *)val);
      #ifdef DBG_CFG
      if(rv==CONFIG_TRUE) {
        printf("CONFIG: setting \"%s\" = %d\n",id,*(int *)val);
      }
      #endif
      break;
    case CFG_POINTS:
      cfg->threshold_polyline = NULL;
      s = config_lookup(hnd,id);
      if(s==NULL) {
        rv = CONFIG_FALSE;
      } else {
        rv = CONFIG_TRUE;
        i = 0;

        #ifdef DBG_CFG
        printf("CONFIG: setting \"%s\" = ( ",id);
        #endif
        while((se = config_setting_get_elem(s,i))!=NULL) {

          cfg->threshold_polyline = realloc(cfg->threshold_polyline,sizeof(ipt_t)*(i+1));
          if(config_setting_get_elem(se,0)==NULL) {
            rv = CONFIG_FALSE;
            break;
          }
          cfg->threshold_polyline[i].x = config_setting_get_int_elem(se,0);

          if(config_setting_get_elem(se,0)==NULL) {
            rv = CONFIG_FALSE;
            break;
          }
          cfg->threshold_polyline[i].y = config_setting_get_int_elem(se,1);

          #ifdef DBG_CFG
          printf("(%d,%d) ",cfg->threshold_polyline[i].x,cfg->threshold_polyline[i].y);
          #endif
          cfg->threshold_pts_num+=1;

          i+=1;
        }
        #ifdef DBG_CFG
        printf(")\n");
        #endif
        if(rv==CONFIG_FALSE) {
          if(cfg->threshold_polyline!=NULL) {
            free(cfg->threshold_polyline);
            cfg->threshold_polyline = NULL;
            cfg->threshold_pts_num = 0;
          }
          break;
        }
      }
      break;
  }

  if(rv==CONFIG_FALSE) {
    #ifdef DBG_CFG
    printf("CONFIG: failed to obtain setting \"%s\"\n",id);
    #endif
    return -1;
  }
  return 0;
}

int cfg_load(cfg_t *cfg, char *file_name) {
  int rv;
  config_t *hnd = &(cfg->hnd);

  sprintf(cfg->fname,"%s",file_name);

  config_init(hnd);
  printf("FILENAME: %s\n",file_name);
  rv = config_read_file(hnd,file_name);
  if(rv==CONFIG_FALSE) {
    logprintf("CONFIG: failed to load configuration file\nerror: %s\n",
              config_error_text(hnd));
    rv = -1;
    goto exit_point;
  } else {
    logprintf("CONFIG: configuration file loaded successfully\n");
    rv = 0;
  }

  rv += cfg_read(cfg,"radar_cli_addr",CFG_STR,&cfg->radar_cli_addr);
  rv += cfg_read(cfg,"radar_cli_port",CFG_INT,&cfg->radar_cli_port);
  rv += cfg_read(cfg,"radar_pkt_size",CFG_INT,&cfg->radar_pkt_size);
  rv += cfg_read(cfg,"radar_rcv_timeout",CFG_INT,&cfg->radar_rcv_timeout);
  rv += cfg_read(cfg,"server_rcv_timeout",CFG_INT,&cfg->server_rcv_timeout);
  rv += cfg_read(cfg,"server_snd_timeout",CFG_INT,&cfg->server_snd_timeout);

  rv += cfg_read(cfg,"data_unit_size",CFG_INT,&cfg->data_unit_size);
  rv += cfg_read(cfg,"data_coll_size",CFG_INT,&cfg->data_coll_size);

  rv += cfg_read(cfg,"meas_cycle_iter_delay",CFG_INT,&cfg->meas_cycle_iter_delay);
  rv += cfg_read(cfg,"meas_cycle_dur",CFG_INT,&cfg->meas_cycle_dur);
//  rv += cfg_read(cfg,"meas_mode",CFG_INT,&cfg->meas_mode);

  rv += cfg_read(cfg,"server_addr",CFG_STR,&cfg->server_addr);
  rv += cfg_read(cfg,"server_port",CFG_INT,&cfg->server_port);

  rv += cfg_read(cfg,"window_min",CFG_INT,&cfg->window_min);
  rv += cfg_read(cfg,"window_max",CFG_INT,&cfg->window_max);
  rv += cfg_read(cfg,"threshold_polyline",CFG_POINTS,&cfg->threshold_polyline);

//  rv += cfg_read(cfg,"max_count_fail_detect",CFG_INT,&MAX_COUNT_FAIL_DETECT);
//  rv += cfg_read(cfg,"do_restore",CFG_INT,&do_restore);
//  rv += cfg_read(cfg,"do_check_accel",CFG_INT,&do_check_accel);
//  rv += cfg_read(cfg,"v_avg_n",CFG_INT,&v_avg_n);
//  rv += cfg_read(cfg,"do_recalc_dist",CFG_INT,&do_recalc_dist);

  rv += cfg_read(cfg,"max_fails_num",CFG_INT,&cfg->max_fails_num);
  rv += cfg_read(cfg,"avg_spds_num",CFG_INT,&cfg->avg_spds_num);

  rv += cfg_read(cfg,"do_restore_gaps",CFG_INT,&cfg->do_restore_gaps);
  rv += cfg_read(cfg,"do_check_spd",CFG_INT,&cfg->do_check_spd);
  rv += cfg_read(cfg,"do_recalc_dist",CFG_INT,&cfg->do_recalc_dist);
  rv += cfg_read(cfg,"do_avg_spd",CFG_INT,&cfg->do_avg_spd);
  rv += cfg_read(cfg,"do_check_dist",CFG_INT,&cfg->do_check_dist);

  return rv;

exit_point:
  config_destroy(hnd);

  return rv;
}

void cfg_update_th_pts(cfg_t *cfg, ipt_t *pts, int npts) {

}

void cfg_unload(cfg_t *cfg) {
  config_destroy(&(cfg->hnd));
}
