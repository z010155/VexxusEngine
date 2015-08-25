<?php
if($_POST){
$error = false;
    if(empty($_POST["itemName"])){
        $error = true;
        $errormsg .= "You're missing item name<br/>";
    }
    if(empty($_POST["itemIcon"])){
        $error = true;
        $errormsg .= "You're missing item icon<br/>";
    }
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Yo, editin' an item, eh?</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Change up all the fields.
                        </div>
                        <div class="panel-body">
            <?php
            if($error == true){
                echo $errormsg."<br/>";
            } else if($error == false && $_POST){
               			// query
			$sql = "UPDATE items SET name=:name, icon=:icon, `desc`=:desc, damage=:damage, cost=:cost, sellPrice=:sellPrice, access=:access, currency=:currency, rarity=:rarity, maxStack=:maxStack, type=:type, itemData=:itemData, linkage=:linkage WHERE id=:id";
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
                              ':linkage'=>$_POST["itemLinkage"],
                              ':id'=>$_GET["ien"]));
			die("Item edited.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }


		$stmt = $db->prepare('SELECT * FROM items WHERE id=:id LIMIT 1');
		$stmt->execute(array(':id'=>$_GET["ien"]));

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                            ?>
                            <form method="POST" action="Main.php?div=editItem&ien=<?php echo $row["id"];?>" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="itemName" value="<?php echo $row["name"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Description</label>
                                            <textarea name="itemDesc" class="form-control" rows="3"><?php echo $row["desc"];?></textarea>
                                        </div>
                                        <div class="form-group">
                                            <label>Icon</label>
                                            <input name="itemIcon" value="<?php echo $row["icon"];?>" class="form-control">
                                        </div>
                                     <div class="form-group">
                                            <label>Damage</label>
                                            <input name="itemDamage" value="<?php echo $row["damage"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Cost</label>
                                            <input name="itemCost" value="<?php echo $row["cost"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Sell price</label>
                                            <input name="itemPrice" value="<?php echo $row["sellPrice"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Access</label>
                                            <select name="itemAccess" class="form-control">
                                                <option <?php if($row["access"] == 1){ echo "selected";}?> value="1">Users</option>
                                                <option <?php if($row["access"] == 2){ echo "selected";}?> value="2">Members</option>
                                                <option <?php if($row["access"] == 3){ echo "selected";}?> value="3">Moderators</option>
                                                <option <?php if($row["access"] == 4){ echo "selected";}?> value="4">Staff</option>
                                                <option <?php if($row["access"] == 5){ echo "selected";}?> value="5">Administrators *</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Currency</label>
                                            <input name="itemCurrency" value="<?php echo $row["currency"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Rarity</label>
                                            <input name="itemRarity" value="<?php echo $row["rarity"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Max stack</label>
                                            <input name="itemStack" value="<?php echo $row["maxStack"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Type</label>
                                            <input name="itemType" value="<?php echo $row["type"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Item data</label>
                                            <input name="itemData" value="<?php echo $row["itemData"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Linkage</label>
                                            <input name="itemLinkage" value="<?php echo $row["linkage"];?>" class="form-control">
                                        </div>

                                        <button type="submit" class="btn btn-success">Edit item</button>
                                    </form>
                            <?php
            }
                            ?>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->