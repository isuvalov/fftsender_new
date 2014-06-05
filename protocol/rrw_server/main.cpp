#include <UdpServer.h>
UdpServer server;
void close(void) {
  server.stop();
  cout << "OK" << endl << "---------" << endl <<"Programm exit.";
}

int main(int argc, char *argv[]) {
    //char buf[512];
    //while (eudp_recv_from_file(buf, 512) == 0);
    //return 0;
    atexit(close);
    server.start();
    return 0;
}

/*
#include <Processor.h>
int main(int argc, char *argv[]) {

    Processor proc;
    proc.find_target();


    return 0;
}
*/
