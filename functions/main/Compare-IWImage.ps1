function Compare-IWImage {
    param(
        # Path to an iso image.iso
        [Parameter(Mandatory)]
        $ReferenceImage,

        # Path to a local image.iso
        [Parameter(Mandatory)]    
        $DifferenceImage
    )

    if ($ReferenceImage -eq $DifferenceImage) {
        Write-PSFMessage -Level Host -Message "Pathes are identically no need to verify." -Tag 'Image'
        return $true
    }
    
    $ReferenceObject = Get-FileHash $ReferenceImage
    $DifferenceObject = Get-FileHash -Path $DifferenceImage

    if (-not (Compare-Object -ReferenceObject $ReferenceObject.Hash -DifferenceObject $DifferenceObject.Hash)) {
        Write-PSFMessage -Level Host -Message "The local and the remote iso is identically." -Tag 'Image'
        return $true
    } else {
        Write-PSFMessage -Level Host -Message "The local and the remote iso is different." -Tag 'Image'
        return $false
    }
}