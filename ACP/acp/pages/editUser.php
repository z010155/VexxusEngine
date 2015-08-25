<?php
if($_POST){
$error = false;
    if(empty($_POST["username"])){
        $error = true;
        $errormsg .= "You're missing username??<br/>";
    }
    if(empty($_POST["password"])){
        $error = true;
        $errormsg .= "You're missing password??<br/>";
    }
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">This someone you know?</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Decrease all the golds
                        </div>
                        <div class="panel-body">
            <?php
            if($error == true){
                echo $errormsg."<br/>";
            } else if($error == false && $_POST){
               			// query
			$sql = "UPDATE characters SET username=:uname, password=:pword, email=:email, access=:access, gold=:gold, xp=:xp, level=:level, classId=:classid, armorId=:armorid, weaponId=:weaponid, gender=:gender, inventorySlots=:inventorySlots, lastZone=:lastZone, lastRoom=:lastRoom, quests=:quests WHERE id=:id";
			$q = $db->prepare($sql);
			$q->execute(array(':uname'=>$_POST["username"],
                              ':pword'=>$_POST["password"],
                              ':email'=>$_POST["email"],
                              ':access'=>$_POST["access"],
                              ':gold'=>$_POST["gold"],
                              ':xp'=>$_POST["xp"],
                              ':level'=>$_POST["level"],
                              ':classid'=>$_POST["classId"],
                              ':armorid'=>$_POST["armorId"],
                              ':weaponid'=>$_POST["weaponId"],
                              ':gender'=>$_POST["gender"],
                              ':inventorySlots'=>$_POST["inventorySlots"],
                              ':lastZone'=>$_POST["lastZone"],
                              ':lastRoom'=>$_POST["lastRoom"],
                              ':quests'=>$_POST["quests"],
                              ':id'=>$_GET["ien"]));
			die("User edited.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }


		$stmt = $db->prepare('SELECT * FROM characters WHERE id=:id LIMIT 1');
		$stmt->execute(array(':id'=>$_GET["ien"]));

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                            ?>
                            <form method="POST" action="Main.php?div=editUser&ien=<?php echo $row["id"];?>" role="form">
                                        <div class="form-group">
                                            <label>Username</label>
                                            <input name="username" value="<?php echo $row["username"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Password</label>
                                            <input name="password" value="<?php echo $row["password"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>E-mail</label>
                                            <input name="email" value="<?php echo $row["email"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Access</label>
                                            <select name="access" class="form-control">
                                                <option <?php if($row["access"] == 0){ echo "selected";}?> value="0">BANNED</option>
                                                <option <?php if($row["access"] == 1){ echo "selected";}?> value="1">Users</option>
                                                <option <?php if($row["access"] == 2){ echo "selected";}?> value="2">Members</option>
                                                <option <?php if($row["access"] == 3){ echo "selected";}?> value="3">Moderators</option>
                                                <option <?php if($row["access"] == 4){ echo "selected";}?> value="4">Staff</option>
                                                <option <?php if($row["access"] == 5){ echo "selected";}?> value="5">Administrators *</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Gold</label>
                                            <input name="gold" value="<?php echo $row["gold"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Experience</label>
                                            <input name="xp" value="<?php echo $row["xp"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Level</label>
                                            <input name="level" value="<?php echo $row["level"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Class ID</label>
                                            <input name="classId" value="<?php echo $row["classId"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Armor ID</label>
                                            <input name="armorId" value="<?php echo $row["armorId"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Weapon ID</label>
                                            <input name="weaponId" value="<?php echo $row["weaponId"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Gender</label>
                                            <input name="gender" value="<?php echo $row["gender"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Inventory Slots</label>
                                            <input name="inventorySlots" value="<?php echo $row["inventorySlots"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Last Zone</label>
                                            <input name="lastZone" value="<?php echo $row["lastZone"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Last Room</label>
                                            <input name="lastRoom" value="<?php echo $row["lastRoom"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Quests</label>
                                            <input name="quests" value="<?php echo $row["quests"];?>" class="form-control">
                                        </div>

                                        <button type="submit" class="btn btn-success">Edit user</button>
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