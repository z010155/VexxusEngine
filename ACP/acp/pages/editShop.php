<?php
if($_POST){
$error = false;
    if(empty($_POST["shopName"])){
        $error = true;
        $errormsg .= "You're missing item name<br/>";
    }
    if(empty($_POST["shopContents"])){
        $error = true;
        $errormsg .= "You're missing item description<br/>";
    } 
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Yo, editin' a shop, eh? LOL</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Fix up all the fieldses.
                        </div>
                        <div class="panel-body">
            <?php
            if($error == true){
                echo $errormsg."<br/>";
            } else if($error == false && $_POST){
               			// query
            $shop = $_POST["shopContents"];
            $total = count($shop);
                
            for($i=0; $i < $total; $i++){
                $shopContents .= $shop[$i];
                if(($i+1) < $total){
                    $shopContents .= ",";
                }
            }
                
			$sql = "UPDATE shops SET shopName=:name, shopContents=:contents, access=:access WHERE id=:id";
			$q = $db->prepare($sql);
			$q->execute(array(':name'=>$_POST["shopName"],
							  ':contents'=>$shopContents,
							  ':access'=>$_POST["shopAccess"],
                              ':id'=>$_GET["ien"]));
			die("Shop edited.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }

		$stmt = $db->prepare('SELECT * FROM shops WHERE id=:id LIMIT 1');
		$stmt->execute(array(':id'=>$_GET["ien"]));

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                            ?>
                            <form method="POST" action="Main.php?div=editShop&ien=<?php echo $row["id"];?>" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="shopName" value="<?php echo $row["shopName"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Contents</label>
                                            <select name="shopContents[]" multiple size=15 style='height: 100%;' class="form-control">
                                                <?php
                
        $items = explode(",", $row["shopContents"]);
                
		$stmt2 = $db->prepare('SELECT * FROM items ORDER BY id ASC');
		$stmt2->execute();

		$result2 = $stmt2->fetchAll();
			foreach($result2 as $row2) {
                if(in_array($row2["id"], $items)){
                    echo '<option selected value="'.$row2["id"].'">'.$row2["name"].'</option>';
                } else {
                    echo '<option value="'.$row2["id"].'">'.$row2["name"].'</option>';
                }
            }
                                                ?>

                                            </select>
                                                                                    <div class="form-group">
                                            <label>Access</label>
                                            <select name="shopAccess" class="form-control">
                                                <option <?php if($row["access"] == 1){ echo "selected";}?> value="1">Users</option>
                                                <option <?php if($row["access"] == 2){ echo "selected";}?> value="2">Members</option>
                                                <option <?php if($row["access"] == 3){ echo "selected";}?> value="3">Moderators</option>
                                                <option <?php if($row["access"] == 4){ echo "selected";}?> value="4">Staff</option>
                                                <option <?php if($row["access"] == 5){ echo "selected";}?> value="5">Administrators *</option>
                                            </select>
                                        </div>


                                        <button type="submit" class="btn btn-success">Edit shop</button>
                                    </form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
    <?php
            }
                ?>
            <!-- /.row -->