using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Diagnostics;
using System.Threading;
using Bwg.Burner;
using Bwg.Scsi;
using CmdRecorder.Properties;
using System.IO;
using Bwg.Logging;

namespace CmdRecorder
{
    static class Program
    {
        // The drive selection component
        public static Bwg.Controls.DriveSelectDropDown drive_selector;
        // The BwgBurner logger instance
        public static Logger logger;
        public static Device device;
        public static Drive drive;
        public static SpeedInfo burn_speed;

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Program.drive_selector = new Bwg.Controls.DriveSelectDropDown();
            Program.logger = new Logger();
            Program.setRecordingDrive();
            Program.makeISO(Environment.GetCommandLineArgs()[1], "movie.iso");
            Program.burn("movie.iso");
            Program.delete(Environment.GetCommandLineArgs()[1], "movie.iso");
        }

        /// <summary>
        /// Makes an ISO with the recording contents
        /// </summary>
        /// <param name="folder">The folder that contains the the items to burn</param>
        /// <param name="iso">The destination ISO file</param>
        public static void makeISO(string folder,string iso)
        {
            string arg = " -o " + iso + " " + folder;
            Process process = new Process();
            process.StartInfo.FileName = "mkisofs.exe";
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.Arguments = arg;
            process.Start();
            while (!process.HasExited)
                Thread.Sleep(500);
        }

        /// <summary>
        /// Burns an existing ISO file
        /// </summary>
        /// <param name="iso_name">The iso's name</param>
        public static void burn(string iso_name)
        {
            bool burn = true;
            while (burn)
            {
                bool erase = false;

                // Check for initialization errors
                DiskOperationError status = Program.drive.Initialize();
                if (status != null)
                {
                    MessageBox.Show(status.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

 /*               if (Program.drive.CurrentProfile == Drive.SupportedProfiles.DVD_RW_RestrictedOverwrite ||
                    Program.drive.CurrentProfile == Drive.SupportedProfiles.DVD_RW_SequentialRecording ||
                    Program.drive.CurrentProfile == Drive.SupportedProfiles.DVD_PLUS_R ||
                    Program.drive.CurrentProfile == Drive.SupportedProfiles.DVD_PLUS_RW)
                {*/
                    DiscInformation info;
                    // Read the disk information
                    if (Program.device.ReadDiscInformation(out info) == Device.CommandStatus.Success)
                    {
                        // If the disk is empty 
                        if (info.DiscStatus != DiscInformation.DiscStatusType.EmptyDisc)
                        {
                            DialogResult res;

                            res = MessageBox.Show("The disk in the drive is not erased.  Do you wish to erase the disk?", "Erase", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                            if (res == DialogResult.No)
                            {
                                return;
                            }
                            erase = true;
                        }

                        burn = false;
                        // Erase if necessary
                        if (erase)
                            Program.drive.Erase(Drive.EraseType.Full, false);

                        // Create the disk image to burn
                        DiskBurnImage dsk = new DiskBurnImage(Program.logger);
                        FileDataSource src = new FileDataSource(iso_name);
                        TrackBurnImage t = new TrackBurnImage(TrackBurnImage.TrackType.Data_Mode_1, src);
                        dsk.AddTrack(t);

                        bool notburned = true;
                        while (notburned)
                        {
                            // Burn the disk image onto the media in the drive
                            status = Program.drive.BurnDisk(Drive.BurnType.DontCare, dsk, false, Program.burn_speed);

                            // If we burned sucessfully, eject the disk
                            if (status == null)
                            {
                                Program.device.StartStopUnit(false, Device.PowerControl.NoChange, Device.StartState.EjectDisc);
                                MessageBox.Show("The process finished successfuly. You can play the movie in your DVD player now.", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                notburned = false;
                            }
                            else
                            {
                                string str = "The burn operation failed - " + status.Message;
                                MessageBox.Show(str, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                DialogResult result = MessageBox.Show("Do you want to try burning the movie again?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                                if (result == DialogResult.No)
                                    notburned = false;
                            }
                        }
                    }
                    else
                    {
                        MessageBox.Show("Can't read information from the disk.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        DialogResult result = MessageBox.Show("Do you want to try again?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                        if (result == DialogResult.No)
                            burn = false;
                        else
                            Program.drive.Initialize();
                    }
               // }
/*                else
                {
                    MessageBox.Show("The disk that's in the drive is not supported. Perhaps the disk isn't blank.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    DialogResult result = MessageBox.Show("Do you want to try again with another disk? (if so replace it first)", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                    if (result == DialogResult.No)
                        burn = false;
                    else
                        Program.drive.Initialize();
                }*/
            }
        }

        /// <summary>
        /// Deletes the contents after the successful burn
        /// </summary>
        /// <param name="folder">The folder with the contents to burn in the DVD</param>
        /// <param name="iso">The destination ISO</param>
        public static void delete(string folder, string iso)
        {
            //
            try
            {
                Directory.Delete(folder,true);
            }
            catch { }
            try
            {
                File.Delete(iso);
            }
            catch { }
        }

        /// <summary>
        /// Sets the recording device to use in this session
        /// </summary>
        public static void setRecordingDrive()
        {
            Program.drive_selector.Logger = Program.logger;
            Program.drive_selector.InitializeDeviceList(false);

            if (Program.drive != null)
            {
                Program.drive.Dispose();
                Program.drive = null;
            }

            if (Program.device != null)
            {
                Program.device.Dispose();
                Program.device = null;
            }

            string dname = (string)Program.drive_selector.SelectedItem;
            Program.device = new Device(Program.logger);
            
            if (!Program.device.Open(dname[0]))
            {
                Program.device = null;
                return;
            }

            Program.drive = new Drive(Program.device);
            DiskOperationError status = Program.drive.Initialize();
            if (status != null)
            {
                Program.drive.Dispose();
                Program.device.Dispose();
                Program.device = null;
                Program.drive = null;
                return;
            }

            SpeedInfo[] speeds;
            if (Program.drive.GetWriteSpeeds(out speeds) == null && speeds.GetLength(0) != 0)
                Program.burn_speed = speeds[0];
            else
                Program.burn_speed = null;
        }
    }
}