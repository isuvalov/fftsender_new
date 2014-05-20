#include "CfgClass.h"

CfgClass::CfgClass(string cfg_root)
{
    config = 0;
    if (!cfg_root.empty())
        load(cfg_root);
}

CfgClass::~CfgClass()
{
    if (config != 0)
        delete config;

}

bool CfgClass::is_exist(const char* name) {
    string param_name = name;
    if (!cfg_root.empty())
        param_name = cfg_root + "." + param_name;
    if (config->exists(param_name))
        return true;

    cout << "CONFIG: option " << name;
    if (!cfg_root.empty())
        cout << " in " << cfg_root;
    cout << " doesn't exist." << endl;

    return false;
}

void CfgClass::load(string cfg_root)
{
    if (config != 0)
        delete config;

    // Read the file. If there is an error, report it and exit.
    try {
        config = new Config();
        config->readFile(CFG_FILE);
        this->cfg_root = cfg_root;

        //string msg = "config " + (cfg_root.empty() ? "" : "for " + cfg_root) + " is loaded successfully!\n";
        //cout << msg;
    }
    catch(const FileIOException &fioex) {
        std::cerr << "I/O error while reading file." << std::endl;
    }
    catch(const ParseException &pex) {
        std::cerr << "Parse error at " << pex.getFile() << ":" << pex.getLine()
                  << " - " << pex.getError() << std::endl;
    }
}

bool CfgClass::isLoaded()
{
    return config != 0;

}

const Setting& CfgClass::operator[](const char* name)
{

    string param_name = name;
    if (!cfg_root.empty())
        param_name = cfg_root + "." + param_name;


    try {
        const Setting& set = config->lookup(param_name);
        return set;
    }
    catch(const SettingNotFoundException &nfex) {
        cerr << "Error config: " << param_name << " is not found." << endl;
    }
}

//return array of points (X,Y)
/*
points_t CfgClass::read_array(const char* name)
{
    string param_name = name;
    if (!cfg_root.empty())
        param_name = cfg_root + "." + param_name;

    points_t points;
    if (is_exist(name)) {
        const Setting& pnts = (*this)[name];
        int count = pnts.getLength();

        for(int i = 0; i < count; ++i) {
            vector<unsigned short> pt;
            int x = pnts[i][0];
            int y = pnts[i][1];
            pt.push_back(x);
            pt.push_back(y);
            points.push_back(pt);
        }
    }
    return points;
}
*/
