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
        # Add log "Pathes are identically no need to verify."
        return $true
    }
    
    $ReferenceObject = Get-FileHash $ReferenceImage
    $DifferenceObject = Get-FileHash -Path $DifferenceImage

    if (-not (Compare-Object -ReferenceObject $ReferenceObject.Hash -DifferenceObject $DifferenceObject.Hash)) {
        # Add log "The local and the remote iso is identically."
        return $true
    } else {
        # Add log "The local and the remote iso is different."
        return $false
    }
}