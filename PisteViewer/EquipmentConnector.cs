/* (c) Copyright Oliver Smith 2008 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PisteView
{
    public interface EquipmentConnector
    {
        void showSettings(PisteViewer view);
        void connect();
        void disconnect();
        string name();
    }
}
