
# poscar2xsf
Requirment: bc and awk commands are available on the Linux or Mac OS. 

pos2xsf.sh: a bash script file that can convert a POSCAR-format-like file to a XSF-format like file.

Usage:   

          chmod +x pos2xsf.sh

          pos2xsf.sh    POSCAR  >POSCAR.xsf
# voutcar2xsf
Requirment: bc and awk commands are available on the Linux or Mac OS. 

voutcar2xsf.sh:  a bash script file that can extract the last structure configuration from the OUTCAR file.

Usage: 
       
       chmod +x voutcar2xsf.sh

       voutcar2xsf.sh   OUTCAR   >OUTCAR.xsf
 
# combine poscar2xsf.sh / voutcar2xsf.sh with XCrySDen
1. check the directory "$HOME/.xcrysden/" is available or not; if not, run command: mkdir $HOME/.xcrysden/;

2. check the "custom-definitions" and  "Xcrysden_defaults" files are available in the directory "$HOME/.xcrysden/" or not; if not, download the files of "custom-definitions" and "Xcrysden_defaults" from here and then put them into "$HOME/.xcrysden/";

3. put "voutcar2xsf.sh" and "pos2xsf.sh" into the "$HOME/bin" directory;

4. add the following example lines ("your_username" should be replaced by your actual username.) into the "custom-definitions" file, :


           addOption --vasp /home/your_username/bin/pos2xsf.sh {
                 load structure from vasp file format
                  }
                  
           addOption --outcar /home/your_username/bin/voutcar2xsf.sh {
                    load structure from vasp file format
                  }
  5. To directly visualize the POSCAR-format-like file or OUTCAR-format-like file via XCrySDen, one can run the following command:
  
          xcrysden --vasp    POSCAR
  
  or
  
          xcrysden --outcar   OUTCAR
  



          

