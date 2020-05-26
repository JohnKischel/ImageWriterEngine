Describe "Mount-IWImage" {
    Context "When an iso is mounted" {
            Mock Mount-IWImage {return (Import-Clixml -Path ".\tests\mockobjects\isoimage.xml")}
        
    It "Should return a cimclass of MSFT_Volume"{
        $result = Mount-IWImage -ImagePath ".\Test.iso"
        $result.CimClass | Should Be "ROOT/Microsoft/Windows/Storage:MSFT_Volume"
    }

    It "Should have a driveletter"{
        $result = Mount-IWImage -ImagePath ".\Test.iso"
        $result.Driveletter.GetType() | Should Be char
    }

    }
}