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
                    <h1 class="page-header">Yo, addin' a shop, eh? GL</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Fill all the fieldses.
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
                
			$sql = "INSERT INTO shops (shopName, shopContents, access) VALUES (:name, :contents, :access)";
			$q = $db->prepare($sql);
			$q->execute(array(':name'=>$_POST["shopName"],
							  ':contents'=>$shopContents,
							  ':access'=>$_POST["shopAccess"]));
			die("Shop added.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }
                            ?>
                            <form method="POST" action="Main.php?div=addShops" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="shopName" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Contents</label>
                                            <select name="shopContents[]" multiple size=15 style='height: 100%;' class="form-control">
                                                <?php
		$stmt = $db->prepare('SELECT * FROM items ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                echo '<option value="'.$row["id"].'">'.$row["name"].'</option>';
            }
                                                ?>

                                            </select>
                                </div>
                                                                                    <div class="form-group">
                                            <label>Access</label>
                                            <select name="shopAccess" class="form-control">
                                                <option value="1">Users</option>
                                                <option value="2">Members</option>
                                                <option value="3">Moderators</option>
                                                <option value="4">Staff</option>
                                                <option value="5">Administrators *</option>
                                            </select>
                                        </div>


                                        <button type="submit" class="btn btn-primary">Add shop</button>
                                    </form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->