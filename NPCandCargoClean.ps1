    $filePath = 'yoursavepath\SANDBOX_0_0_0_.sbs'
    $filePath2 = 'yoursavepath\SANDBOX.sbc'

    [xml]$myXML = Get-Content $filePath
    $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
    $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    [xml]$myXML2 = Get-Content $filePath2
    $ns2 = New-Object System.Xml.XmlNamespaceManager($myXML2.NameTable)
    $ns2.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    #cargo ship and related save cleanup.
    Write-Host -ForegroundColor Green "Cargo Ship Cleaning ....  "
    [string]$compare = "360"
    $NPCPlayerID = $myXML2.SelectNodes("//Identities/MyObjectBuilder_Identity/PlayerId" , $ns2)
    ForEach($ID in $NPCPlayerID){
        $NPCID = [string]$ID.InnerText[0] + [string]$ID.InnerText[1] + [string]$ID.InnerText[2]
        If($NPCID -eq $compare){
            Write-Host -ForegroundColor Green " NPC ID and owned blocks deleteing ... "
            $NPCnodeOwns = $myXML.SelectNodes("//CubeBlocks/MyObjectBuilder_CubeBlock[Owner='$($ID.InnerText)']"  , $ns)
            ForEach($NPCOwned in $NPCnodeOwns){
            Write-Host -ForegroundColor Green " $($NPCOwned.SubtypeName) deleted!"
            $NPCOwned.ParentNode.RemoveChild($NPCOwned)
            }
            $ID.ParentNode.ParentNode.RemoveChild($ID.ParentNode)
        }
    }

    $myXML.Save($filePath)
    $myXML2.Save($filePath2)