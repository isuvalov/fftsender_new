#include <stdio.h>
#include <stdlib.h>

#include <rrw_server.h>
#include <radar_cli.h>

int main()
{
  srv_t srv;
  rcli_t cli;
  rdr_t rdr;
  
  eudp_start();
  
  rdr_init(&rdr,"127.0.0.1",65002,514,rcli_collect);
  rdr_conn(&rdr);
  rcli_init(&cli,&rdr);
  
  srv_init(&srv,"127.0.0.1",60606,&cli);
  srv_open(&srv);
  
  srv_start(&srv);
  
  srv_close(&srv);
  rcli_deinit(&cli);
  rdr_disconn(&rdr);
  rdr_deinit(&rdr);

  eudp_finish();

    return 0;
}
