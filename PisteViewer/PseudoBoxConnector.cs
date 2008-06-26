/* (c) Copyright Oliver Smith 2008 */


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PisteView
{
    class PseudoBoxConnector : EquipmentConnector
    {
        #region EquipmentConnector Members

        public void showSettings(PisteViewer view)
        {
        
            // We have the test scenario
            PseudoBox box = new PseudoBox(view);
            box.Show();
          
        }

        public void connect() { }
        public void disconnect() { }
        public string name() 
        {
            return "Pseudo Box for testing";
        }

        #endregion
    }
}
