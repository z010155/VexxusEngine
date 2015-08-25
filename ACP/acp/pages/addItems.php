<?php
if($_POST){
$error = false;
    if(empty($_POST["itemName"])){
        $error = true;
        $errormsg .= "You're missing item name<br/>";
    }
    if(empty($_POST["itemDesc"])){
        $error = true;
        $errormsg .= "You're missing item description<br/>";
    } 
    if(empty($_POST["itemIcon"])){
        $error = true;
        $errormsg .= "You're missing item icon<br/>";
    }
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Yo, addin' an item, eh?</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Fill all the fields.
                        </div>
                        <div class="panel-body">
            <?php
            if($error == true){
                echo $errormsg."<br/>";
            } else if($error == false && $_POST){
               			// query
			$sql = "INSERT INTO items (name, icon, `desc`, damage, cost, sellPrice, access, currency, rarity, maxStack, type, itemData, linkage) VALUES (:name, :icon, :desc, :damage, :cost, :sellPrice, :access, :currency, :rarity, :maxStack, :type, :itemData, :linkage)";
			$q = $db->prepare($sql);
			$q->execute(array(':name'=>$_POST["itemName"],
							  ':icon'=>$_POST["itemIcon"],
							  ':desc'=>$_POST["itemDesc"],
							  ':damage'=>$_POST["itemDamage"],
							  ':cost'=>$_POST["itemCost"],
							  ':sellPrice'=>$_POST["itemPrice"],
							  ':access'=>$_POST["itemAccess"],
							  ':currency'=>$_POST["itemCurrency"],
                              ':rarity'=>$_POST["itemRarity"],
                              ':maxStack'=>$_POST["itemStack"],
                              ':type'=>$_POST["itemType"],
                              ':itemData'=>$_POST["itemData"],
                              ':linkage'=>$_POST["itemLinkage"]));
			die("Item added.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }
                            ?>
                            <form method="POST" action="Main.php?div=addItems" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="itemName" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Description</label>
                                            <textarea name="itemDesc" class="form-control" rows="3"></textarea>
                                        </div>
                                        <div class="form-group">
                                            <label>Icon</label>
                                            <input name="itemIcon" class="form-control">
                                        </div>
                                     <div class="form-group">
                                            <label>Damage</label>
                                            <input name="itemDamage" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Cost</label>
                                            <input name="itemCost" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Sell price</label>
                                            <input name="itemPrice" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Access</label>
                                            <select name="itemAccess" class="form-control">
                                                <option value="1">Users</option>
                                                <option value="2">Members</option>
                                                <option value="3">Moderators</option>
                                                <option value="4">Staff</option>
                                                <option value="5">Administrators *</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Currency</label>
                                            <input name="itemCurrency" value="0" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Rarity</label>
                                            <input name="itemRarity" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Max stack</label>
                                            <input name="itemStack" value="1" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Type</label>
                                            <input name="itemType" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Item data</label>
                                            <input name="itemData" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Linkage</label>
                                            <input name="itemLinkage" class="form-control">
                                        </div>

                                        <button type="submit" class="btn btn-primary">Add item</button>
                                    </form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->