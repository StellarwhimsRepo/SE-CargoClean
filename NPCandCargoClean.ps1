    $filePath = 'yoursavepath\SANDBOX_0_0_0_.sbs'
    $filePath2 = 'yoursavepath\SANDBOX.sbc'

    [xml]$myXML = Get-Content $filePath -Encoding UTF8
    $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
    $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    [xml]$myXML2 = Get-Content $filePath2 -Encoding UTF8
    $ns2 = New-Object System.Xml.XmlNamespaceManager($myXML2.NameTable)
    $ns2.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    #cargo ship and related save cleanup.
    Write-Host -ForegroundColor Green "Cargo Ship Cleaning ....  "
    [string]$compare = "Neutral NPC"
    $NPCPlayerID = $myXML2.SelectNodes("//Identities/MyObjectBuilder_Identity/DisplayName" , $ns2)
    $allgrids = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]", $ns)
    ForEach($ID in $NPCPlayerID){
        $NPCID = [string]$ID.InnerText
        If($NPCID -eq $compare){
        ForEach($grid in $allgrids){
            $npcbeacon=$grid.SelectSingleNode("CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Beacon')]", $ns)
            If($npcbeacon.Owner -eq $ID.ParentNode.IdentityId){
            Write-Host -ForegroundColor Green " NPC ID and owned blocks deleting ... "
            $NPCnodeOwns = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock[Owner='$($ID.ParentNode.IdentityId)']"  , $ns)
            $cargodoors=$grid.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_MotorStator')]",$ns)
            #$cargodoors=$cargodoors.SelectNodes("MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_MotorStator')]", $ns)
            ForEach($cargorotor in $cargodoors){
            $doorID=$cargorotor.RotorEntityId
            IF($doorID -ne 0 -and $doorID -ne $null){
            Write-Host -ForegroundColor Green " NPC Cargo door deleted "
            $targetdoor = $myXML.SelectSingleNode("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_MotorRotor') and EntityId='$doorID']",$ns)
            $targetdoor.ParentNode.ParentNode.ParentNode.RemoveChild($targetdoor.ParentNode.ParentNode)
            }
            }
            ForEach($NPCOwned in $NPCnodeOwns){
            Write-Host -ForegroundColor Green " $($NPCOwned.SubtypeName) deleted!"
            $NPCOwned.ParentNode.RemoveChild($NPCOwned)
            }
            #$ID.ParentNode.ParentNode.RemoveChild($ID.ParentNode)
            }
        }
        $ID.ParentNode.ParentNode.RemoveChild($ID.ParentNode)
        }
    }

    #enable the below code by removing the <# and #> at the top and bottom of this section
    #this section resets exploration spawn areas.

    <#
    Write-Host -ForegroundColor Green "Resetting Exploration Encounters ....  "
    $movedencounters = $myXML.MyObjectBuilder_Sector.Encounters.MovedOnlyEncounters.dictionary.item
    $savedencounters = $myXML.MyObjectBuilder_Sector.Encounters.SavedEcounters.MyEncounterId
    ForEach($Encounter in $allencounters){
    $Encounter.ParentNode.RemoveChild($Encounter)
    }
    ForEach($MEncounter in $movedencounters){
    $MEncounter.ParentNode.RemoveChild($MEncounter)
    }
    Write-Host -ForegroundColor Green "Exploration Encounters Reset!!  "
    #>

    $myXML.Save($filePath)
    $myXML2.Save($filePath2)