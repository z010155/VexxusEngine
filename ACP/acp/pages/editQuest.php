<?php
if($_POST){
$error = false;
    if(empty($_POST["questName"])){
        $error = true;
        $errormsg .= "You're missing quest name<br/>";
    }
    
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">LOL more questingses?</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Fill all the fieldses. J/K I ONLY CHECK FOR NAME HUEHUE
                        </div>
                        <div class="panel-body">
            <?php
            if($error == true){
                echo $errormsg."<br/>";
            } else if($error == false && $_POST){
               			// query
                
			$sql = "UPDATE quests SET name=:name, startText=:startText, endText=:endText, objectives=:objectives, rewards=:rewards, reqQuest=:reqQuest, oneTime=:oneTime, isDaily=:isDaily, reqLevel=:reqLevel, access=:access WHERE id=:id";
			$q = $db->prepare($sql);
			$q->execute(array(':name'=>$_POST["questName"],
							  ':startText'=>$_POST["questStart"],
                              ':endText'=>$_POST["questEnd"],
                              ':objectives'=>$_POST["questObjectives"],
                              ':rewards'=>$_POST["questRewards"],
                              ':reqQuest'=>$_POST["questReq"],
                              ':oneTime'=>$onetime,
                              ':isDaily'=>$isdaily,
                              ':reqLevel'=>$_POST["reqLevel"],
							  ':access'=>$_POST["questAccess"],
                              ':id'=>$_GET["ien"]
                                ));
			die("Quest added.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }

$stmt = $db->prepare('SELECT * FROM quests WHERE id=:id LIMIT 1');
		$stmt->execute(array(':id'=>$_GET["ien"]));

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                            ?>
                            <form method="POST" action="Main.php?div=editQuest&ien=<?php echo $row["id"];?>" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="questName" class="form-control" value="<?php echo $row["name"];?>">
                                        </div>
                                <div class="form-group">
                                            <label>Starting text</label>
                                            <input name="questStart" class="form-control" value="<?php echo $row["startText"];?>">
                                        </div>
                                <div class="form-group">
                                            <label>Ending text</label>
                                            <input name="questEnd" class="form-control" value="<?php echo $row["endText"];?>">
                                        </div>
                                <div class="form-group">
                                            <label>Objectives</label>
                                            <input name="questObjectives" class="form-control" value="<?php echo $row["objectives"];?>">
                                        </div>
                                <div class="form-group">
                                            <label>Rewards</label>
                                            <input name="questRewards" class="form-control" value="<?php echo $row["rewards"];?>">
                                        </div>
                                <div class="form-group">
                                            <label>Required quests</label>
                                            <input name="questReq" class="form-control" value="<?php echo $row["reqQuest"];?>">
                                        </div>
                                <div class="form-group">
                                    <label>Required level</label>
                                    <input name="reqLevel" class="form-control" value="<?php echo $row["reqLevel"];?>">
                                </div>

                                <div class="form-group">
                                            <label>Access</label>
                                            <select name="questAccess" class="form-control">
                                                <option <?php if($row["access"] == 1){ echo "selected";}?> value="1">Users</option>
                                                <option <?php if($row["access"] == 2){ echo "selected";}?> value="2">Members</option>
                                                <option <?php if($row["access"] == 3){ echo "selected";}?> value="3">Moderators</option>
                                                <option <?php if($row["access"] == 4){ echo "selected";}?> value="4">Staff</option>
                                                <option <?php if($row["access"] == 5){ echo "selected";}?> value="5">Administrators *</option>
                                            </select>
                                        </div>


                                        <button type="submit" class="btn btn-primary">Add quest</button>
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