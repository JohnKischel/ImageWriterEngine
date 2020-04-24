function Compare-IWImage
{
    param(
        # Path to an iso image.iso
        [Parameter(Mandatory)]
        $ReferenceImage,

        # Path to a local image.iso
        [Parameter(Mandatory)]    
        $DifferenceImage
    )

    $ReferenceObject = Get-FileHash $ReferenceImage
    $DifferenceObject = Get-FileHash -Path $DifferenceImage

    if(-not (Compare-Object -ReferenceObject $ReferenceObject.Hash -DifferenceObject $DifferenceObject.Hash))
    {
        Write-PSFMessage -Level Host -Message "The local and the remote iso are identically."
        return $true
    }
    else{
        Write-PSFMessage -Level Host -Message "The local and the remote iso are different."
        return $false
    }
}