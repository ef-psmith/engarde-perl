/* (c) Copyright Oliver Smith 2008 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO.Ports;

namespace PisteView
{
    /*
     * Connector for Leon Paul boxes & probably other rebrandings of the same box
     * Serial port based.
     */
    public class SGConnector : EquipmentConnector
    {
        private static int SOH = 0x01;
        private static int DC3 = 0x13;
        private static int EOT = 0x04;

        #region Functor Classes
        private interface ViewerFunctor
        {
            void Execute();
            int Initialise(byte[] buffer, int index, int size);
            bool isInitialised();
        }
        private class SetLights : ViewerFunctor
        {
            private bool red_;
            private bool red_white_;
            private bool green_;
            private bool green_white_;
            private int bytes_read_;
            private PisteViewer viewer_;

            public SetLights(PisteViewer viewer) {
                red_ = false;
                red_white_ = false;
                green_ = false;
                green_white_ = false;
                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size) {
                // Do nothing if we are already initialised
                if (8 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)) ) {
                    switch (bytes_read_) {
                        case 0:
                            // SOH, DC3 and ID have been swallowed already
                            // Should be "R" but don't really care
                            break;
                        case 1:
                            // State of the red light
                            red_ = (1 == buffer[index + offset]);
                            break;
                        case 2:
                            // Should be 'G' but we don't care
                            break;
                        case 3:
                            // State of the green light
                            green_ = (1 == buffer[index + offset]);
                            break;
                        case 4:
                            // Should be 'W' but we don't care
                            break;
                        case 5:
                            red_white_ = (1 == buffer[index + offset]);
                            break;
                        case 6:
                            // Should be 'W' but we don't care
                            break;
                        case 7:
                            green_white_ = (1 == buffer[index + offset]);
                            break;
                        case 8:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute() {
                viewer_.showLights(red_, red_white_,green_,green_white_);
            }
            public bool isInitialised()
            {
                return bytes_read_ > 8;
            }
        }
        private class SetScore : ViewerFunctor
        {
            private int left_score_;
            private int right_score_;

            private int bytes_read_;
            private PisteViewer viewer_;

            public SetScore(PisteViewer viewer)
            {
                left_score_ = 0;
                right_score_ = 0;
                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size)
            {
                // Do nothing if we are already initialised
                if (5 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)))
                {
                    switch (bytes_read_)
                    {
                        case 0:
                            // Right 10s
                            right_score_ += 10 * (int)buffer[index + offset];
                            break;
                        case 1:
                            // Right units
                            right_score_ += (int)buffer[index + offset];
                            break;
                        case 2:
                            // Should be ':' but we don't care
                            break;
                        case 3:
                            // Left 10s
                            left_score_ += 10 * (int)buffer[index + offset];
                            break;
                        case 4:
                            // Left units
                            left_score_ += (int)buffer[index + offset];
                            break;
                        case 5:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute()
            {
                viewer_.setScore(left_score_ , right_score_);
            }
            public bool isInitialised()
            {
                return bytes_read_ > 5;
            }
        }
        private class SetTime : ViewerFunctor
        {
            private int time_left_;

            private int bytes_read_;
            private PisteViewer viewer_;

            public SetTime(PisteViewer viewer)
            {
                time_left_ = 0;

                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size)
            {
                // Do nothing if we are already initialised
                if (5 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)))
                {
                    switch (bytes_read_)
                    {
                        case 0:
                            // Minute 10s
                            time_left_ += 600 * (int)buffer[index + offset];
                            break;
                        case 1:
                            // Minute units
                            time_left_ += 60 * (int)buffer[index + offset];
                            break;
                        case 2:
                            // Should be ':' but we don't care
                            break;
                        case 3:
                            // Second 10s
                            time_left_ += 10 * (int)buffer[index + offset];
                            break;
                        case 4:
                            // second units
                            time_left_ += (int)buffer[index + offset];
                            break;
                        case 5:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute()
            {
                viewer_.setTime(time_left_);
            }
            public bool isInitialised()
            {
                return bytes_read_ > 5;
            }
        }
        private class SetMatchNum : ViewerFunctor
        {
            private int match_num_;

            private int bytes_read_;
            private PisteViewer viewer_;

            public SetMatchNum(PisteViewer viewer)
            {
                match_num_ = 0;

                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size)
            {
                // Do nothing if we are already initialised
                if (2 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)))
                {
                    switch (bytes_read_)
                    {
                        case 0:
                            // match 10s
                            match_num_ += 10 * (int)buffer[index + offset];
                            break;
                        case 1:
                            // match units
                            match_num_ += (int)buffer[index + offset];
                            break;
                        
                        case 2:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute()
            {
                // Do nothing at present
            }
            public bool isInitialised()
            {
                return bytes_read_ > 2;
            }
        }
        private class SetPriority : ViewerFunctor
        {
            private int priority_; // 0 - none, 1 - right, 2 - left

            private int bytes_read_;
            private PisteViewer viewer_;

            public SetPriority(PisteViewer viewer)
            {
                priority_ = 0;

                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size)
            {
                // Do nothing if we are already initialised
                if (3 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)))
                {
                    switch (bytes_read_)
                    {
                        case 0:
                            // Priority
                            priority_ = (int)buffer[index + offset];
                            break;
                        case 1:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute()
            {
                // Do nothing at present
            }
            public bool isInitialised()
            {
                return bytes_read_ > 1;
            }
        }
        private class SetCards : ViewerFunctor
        {
            private int left_card_;
            private int left_card_num_;
            private int right_card_;
            private int right_card_num_;

            private int bytes_read_;
            private PisteViewer viewer_;

            public SetCards(PisteViewer viewer)
            {
                left_card_ = 0;
                left_card_num_ = 0;
                right_card_ = 0;
                right_card_num_ = 0;

                bytes_read_ = 0;
                viewer_ = viewer;
            }

            public int Initialise(byte[] buffer, int offset, int size)
            {
                // Do nothing if we are already initialised
                if (4 < bytes_read_)
                    return offset;

                bool finished = false;
                int index = 0;
                while (!finished && (size > (index + offset)))
                {
                    switch (bytes_read_)
                    {
                        case 0:
                            // Cards for the left fencer
                            left_card_ = (int)buffer[index + offset];
                            break;
                        case 1:
                            // Cards for the right fencer
                            right_card_ = (int)buffer[index + offset];
                            break;
                        case 2:
                            // Number of cards for left fencer
                            left_card_num_ = (int)buffer[index + offset];
                            break;
                        case 3:
                            // Number of cards for right fencer
                            right_card_num_ = (int)buffer[index + offset];
                            break;
                        case 4:
                            // should be EOT
                            if (EOT == buffer[index + offset])
                                finished = true;
                            // else throw exception
                            break;
                        default:
                            // throw an exception
                            break;
                    }
                    //Move to next byte
                    ++bytes_read_;
                    ++index;
                }
                return index + offset;
            }
            public void Execute()
            {
                // Do nothing
            }
            public bool isInitialised()
            {
                return bytes_read_ > 4;
            }
        }


        #endregion

        // The main control for communicating through the RS-232 port
        private SerialPort comport_ = new SerialPort();
        private byte[] incomplete_message_;
        private string equip_name_;
        private ViewerFunctor incomplete_functor_;
        private PisteViewer parent_;

        #region Serial Port Properties
        private int baudRate_;
        public int baudRate
        {
            get
            {
                return baudRate_;
            }
            set
            {
                baudRate_ = value;
            }
        }
        private int dataBits_;
        public int dataBits
        {
            get
            {
                return dataBits_;
            }
            set
            {
                dataBits_ = value;
            }
        }
        private StopBits stopBits_;
        public StopBits stopBits
        {
            get
            {
                return stopBits_;
            }
            set
            {
                stopBits_ = value;
            }
        }
        private Parity parity_;
        public Parity parity
        {
            get
            {
                return parity_;
            }
            set
            {
                parity_ = value;
            }
        }
        private String portName_;
        public String portName
        {
            get
            {
                return portName_;
            }
            set
            {
                portName_ = value;
            }
        }
        #endregion

        public SGConnector(string name, PisteViewer parent)
        {
            parent_ = parent;
            baudRate_ = 9600;
            dataBits_ = 8;
            stopBits_ = StopBits.None;
            portName_ = "COM8";
            parity_ = Parity.None;
            equip_name_ = name;
        }

        private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            // This method will be called when there is data waiting in the port's buffer

            // Obtain the number of bytes waiting in the port's buffer
            int bytes = comport_.BytesToRead;

            // Create a byte array buffer to hold the incoming data
            byte[] buffer = new byte[bytes];

            // Read the data from the port and store it in our buffer
            comport_.Read(buffer, 0, bytes);

            int offset = 0;
            
            if (null != incomplete_message_) 
                offset = incomplete_message_.GetLength(0);

            if (3 <= offset)
            {
                // Parsing error, we should have created a Functor
            }

            int bytes_read = 0;
            // Deal with an incomplete functor
            if (null != incomplete_functor_)
            {
                bytes_read = incomplete_functor_.Initialise(buffer, 0, bytes);
                if (incomplete_functor_.isInitialised())
                {
                    incomplete_functor_.Execute();
                    incomplete_functor_ = null;

                }
            }
            if (null == incomplete_functor_)
            {
                // So we are trying to create a new functor
                while (bytes_read < bytes + offset)
                {
                    // These come in threes.
                    // Check that we have enough information to create a functor
                    // from the buffer and the stored buffer
                    if (bytes_read + 3 > bytes + offset)
                    {
                        // we can't create a new functor
                        byte[] oldbuffer = incomplete_message_;
                        incomplete_message_ = new byte[offset + bytes - bytes_read];
                        // Copy the old buffer
                        int pos = 0;
                        if (null != oldbuffer)
                        {
                            for (int i = 0; i < oldbuffer.GetLength(0); ++i)
                            {
                                incomplete_message_[pos++] = oldbuffer[i];
                            }
                        }
                        while (bytes_read < bytes)
                        {
                            incomplete_message_[pos++] = buffer[bytes_read++];
                        }
                    }
                    else
                    {
                        // Set the place to the next type
                        bytes_read = bytes_read + 3 - offset;
                        // Clear out the old buffer
                        incomplete_message_ = null; 
                        offset = 0;

                        byte type = buffer[bytes_read++];

                        switch (type)
                        {
                            case 0x53: /* 'S' */
                                // Score 
                                incomplete_functor_ = new SetScore(parent_);
                                break;
                            case 0x54: /* 'T' */
                                // Time
                                incomplete_functor_ = new SetTime(parent_);
                                break;
                            case 0x4c: /* 'L' */
                                // Lights
                                incomplete_functor_ = new SetLights(parent_);
                                break;
                            case 0x50: /* 'P' */
                                // Priority
                                incomplete_functor_ = new SetPriority(parent_);
                                break;
                            case 0x4d: /* 'M' */
                                // Match ??
                                incomplete_functor_ = new SetMatchNum(parent_);
                                break;
                            case 0x43: /* 'C' */
                                // Cards
                                incomplete_functor_ = new SetCards(parent_);
                                break;
                            default:
                                // Parsing error
                                // Wait for the next EOT.
                                while (EOT != buffer[bytes_read++] && bytes_read < bytes + offset) ;
                                break;
                        }
                        if (null != incomplete_functor_)
                        {
                            bytes_read = incomplete_functor_.Initialise(buffer, bytes_read, bytes);
                            if (incomplete_functor_.isInitialised())
                            {
                                incomplete_functor_.Execute();
                                incomplete_functor_ = null;
                            }
                        }
                    }
                }
            }

            // Now go parsing...

            // Determain which mode (string or binary) the user is in
            /*if (CurrentDataMode == DataMode.Text)
            {
                // Read all the data waiting in the buffer
                string data = comport.ReadExisting();

                // Display the text to the user in the terminal
                Log(LogMsgType.Incoming, data);
            }
            else
            {
                // Obtain the number of bytes waiting in the port's buffer
                int bytes = comport.BytesToRead;

                // Create a byte array buffer to hold the incoming data
                byte[] buffer = new byte[bytes];

                // Read the data from the port and store it in our buffer
                comport.Read(buffer, 0, bytes);

                // Show the user the incoming data in hex format
                Log(LogMsgType.Incoming, ByteArrayToHexString(buffer));
            }*/
        }


        #region EquipmentConnector Members

        void EquipmentConnector.showSettings(PisteViewer view)
        {
            serialportsettings sett = new serialportsettings(this);
            sett.ShowDialog();
        }

        void EquipmentConnector.connect()
        {
            // If the port is open, close it.
            if (comport_.IsOpen) 
                comport_.Close();
            
           
            // Set the port's settings
            comport_.BaudRate = baudRate_;
            comport_.DataBits = dataBits_;
            comport_.StopBits = stopBits_;
            comport_.Parity = parity_;
            comport_.PortName = portName_;

            // When data is recieved through the port, call this method
            comport_.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);

            // Open the port
            comport_.Open();
            
        }
        void EquipmentConnector.disconnect()
        {
            // If the port is open, close it.
            if (comport_.IsOpen)
                comport_.Close();
        }
        string EquipmentConnector.name()
        {
            return "Leon Paul box";
        }
        #endregion
    }
}
