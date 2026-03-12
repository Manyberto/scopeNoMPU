#!/usr/bin/env python3.11

import io
import logging

from ipdi.ip.pyaip import pyaip, pyaip_init


class scopeNoMPU:
    ## Class constructor of ILI9327 driver
    #
    # @param self Object pointer
    # @param targetConn Middleware object
    # @param config Dictionary with ILI9327 configs
    # @param addrs Network address IP
    # def __init__(self, targetConn, config=None, addrs='IP1:0'):
    def __init__(self, comm, csv_file, nic_addr=1, port=0):
        self.__pyaip = pyaip_init(comm, nic_addr, port, csv_file)
        
        if self.__pyaip is None:
            logging.debug(error)

        self.MemInData = []  # Array with data to save
        ## IP Dummy IP-ID
        self.IPID = 0
        
        self.__getID()

        self.__clearStatus()
        
        logging.info(f"scopeNoMPU controller created with IP ID {self.IPID:08x}")


    def loadMeminIntoLCD(self, pathReal, pathImag):
        self.OpenTxtData(pathReal)
        self.writeDataMEM(0)
        self.OpenTxtData(pathImag)
        self.writeDataMEMIMG(0)



    # Method to create the Array to save in mems in
    def OpenTxtData(self, name):
        self.MemInData = []
        with io.open(name, 'r') as Data2TxtFile:
            line = Data2TxtFile.readline()
            while line:
                line = str(line)
                aa = "0x" + line[0:8]
                # print("string numbers")
                # print(aa)
                self.MemInData.append(int(aa, 0))
                # print(int(aa,0))
                line = Data2TxtFile.readline()

    # Method to load the data into MEMIN
    def writeDataMEM(self, address):

        temp_array = self.MemInData
        dataLen = len(temp_array)
        self.__pyaip.writeMem('MMEMRE', temp_array, dataLen, address)
        # logging.info("tamaño archivo %i" % dataLen)

    # Method to load the data into MEMIN
    def writeDataMEMIMG(self, address):
        temp_array = self.MemInData
        dataLen = len(temp_array)
        self.__pyaip.writeMem('MMEMIM', temp_array, dataLen, address)
        # logging.info("tamaño archivo %i" % dataLen)

    # Method to set and load the configuration registers
    def setConfigReg(self, fs, axisMax, avg, opMode, dotUp, dotLow):

        ## Parámetros fijos:
        fsScaleMax = 8000   # Frecuencia de muestreo máxima permitida
        FFT_length = 128    # tamaño de muestras de la FFT interna
        screenArea = 372    # Puntos de la señal a mapear en el display
        inputDecimFactor = fs // (2 * axisMax)
        #if (inputDecimFactor % 2) == 1:
        #    inputDecimFactor = inputDecimFactor+1
        intpolSel = 4
        sizeIntpol = FFT_length
        sizeDecim = 2 ** (intpolSel + 1) * FFT_length
        decimFactor = sizeDecim // screenArea

        tmp1 = dotLow << 16
        tmp2 = dotUp << 20
        config_word1_field1 = avg + tmp1 + tmp2
        tmp1 = inputDecimFactor-1
        tmp2 = tmp1.bit_length()
        tmp3 = opMode << 31
        tmp4 = (fsScaleMax//fs)-1
        tmp5 = tmp4.bit_length()
        tmp6 = tmp5 << 3
        config_word1_field2 = tmp2 + tmp3 + tmp6
        tmp1 = sizeIntpol << 6
        config_word1_field3 = intpolSel + tmp1
        tmp1 = sizeDecim << 13
        config_word1_field4 = decimFactor + tmp1

        #                        CONFIG_REG  [data], size, ptr_configreg ,  addrIP
        self.__pyaip.writeConfReg('CCONFIG', [config_word1_field1], 1, 0)
        self.__pyaip.writeConfReg('CCONFIG', [config_word1_field2], 1, 1)
        self.__pyaip.writeConfReg('CCONFIG', [config_word1_field3], 1, 2)
        self.__pyaip.writeConfReg('CCONFIG', [config_word1_field4], 1, 3)

    def finish(self):
        self.__pyaip.finish()
    
    ## Start processing in ILI9327
    #
    # @param self Object pointer
    def startIP(self):
        self.__pyaip.start()
    
    ## Get IP ID
    #
    # @param self Object pointer
    def __getID(self):
        self.IPID = self.__pyaip.getID()
        logging.debug(self.IPID)
    
    ## Clear status register of ILI9327
    #
    # @param self Object pointer
    def __clearStatus(self):
        for i in range(8):
            self.__pyaip.clearINT(i)

if __name__=="__main__":
    import sys, random, time, argparse

    #parser = argparse.ArgumentParser(description='Paso de parametros.')
    #parser.add_argument("-c", "--config", help="Archivo de configs")
    #parser.add_argument("-p", "--port", help="Puerto serie")
    #parser.add_argument("-f", "--figure", help="Foto a mostrar en la pantalla")
    #args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG)

    #configFile = args.config
    #port = args.port
    #pictureFile = args.figure

    logging.basicConfig(level=logging.DEBUG)

    config = "../cfg/ID00001011_config.csv"
    port = 'COM3'
    txtPathMemReal = "./input_realData.txt"
    txtPathMemImag = "./input_imagData.txt"

    configFile = config
    port = port
    
    logging.debug("Config: " + configFile)
    logging.debug("Port: " + port)
    #logging.debug("Picture: " + pictureFile)

    try:
        lcd = scopeNoMPU(port, configFile)
        logging.info("Test scopeNoMPU: Driver creado")
    except:
        logging.error("Test scopeNoMPU: Driver NO creado")
        sys.exit()

    ## Parámetros configurables:
    fs = 2000           # Frecuencia de muestreo de la señal a analizar
    fs_axisMax = 250    # Valor máximo deseado del eje frecuencial
    avg = 10            # Número de realizaciones (iteraciones) a promediar. val min = 2
    opMode = 0          # 0 = datos en mem in. 1 = datos por streaming
    dotUpperWidth = 14  # Ancho del marcador en la grafica superior. val min = 0. Even numbers
    dotLowerWidth = 4   # Ancho del marcador en la grafica inferior. val min = 0. Even numbers

    lcd.loadMeminIntoLCD(txtPathMemReal, txtPathMemImag)

    lcd.setConfigReg(fs, fs_axisMax, avg, opMode, dotUpperWidth, dotLowerWidth)
    lcd.startIP()

    while 1:
        lcd.loadMeminIntoLCD(txtPathMemReal, txtPathMemImag)

    lcd.finish()
    
    logging.info("The End")