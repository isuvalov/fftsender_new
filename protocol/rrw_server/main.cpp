#include <UdpServer.h>
UdpServer server;
void close(void) {
  server.stop();
  cout << endl << "---------" << endl <<"Programm exit.";
}

int main(int argc, char *argv[]) {
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
