#ifndef CFGCLASS_H
#define CFGCLASS_H

#include<types.h>
#include <iostream>
#include "libconfig.h++"

using namespace std;
using namespace libconfig;

typedef enum CFG_TYPE {T_INT, T_STR, T_FL, T_BOOL, T_POINTS};


#define CFG_FILE "rrw_server.cfg"

class CfgClass
{
    public:
        CfgClass(string cfg_root = "");

        void load(string cfg_root = "");
        bool isLoaded();

        const Setting& operator[](const char* name);
        //points_t read_array(const char* name);
        ~CfgClass();
        string get_cfg_root() {return cfg_root;};
        bool is_exist(const char* name);
    protected:
    private:

        string cfg_root;
        Config *config;
};

#endif // CFGCLASS_H
