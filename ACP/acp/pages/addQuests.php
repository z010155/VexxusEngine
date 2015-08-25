<?php
if($_POST){
$error = false;
    if(empty($_POST["questName"])){
        $error = true;
        $errormsg .= "You're missing quest name<br/>";
    }
    
    if($_POST["questCompletion"] == 1){
        $onetime = 1;
        $isdaily = 0;
    } else if ($_POST["questCompletion"] == 2){
        $onetime = 0;
        $isdaily = 1;
    } else {
        $onetime = 0;
        $isdaily = 0;
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
                
			$sql = "INSERT INTO quests (name, startText, endText, objectives, rewards, reqQuest, oneTime, isDaily, reqLevel, access) VALUES (:name, :startText, :endText, :objectives, :rewards, :reqQuest, :oneTime, :isDaily, :reqLevel, :access)";
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
                                ));
			die("Quest added.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }
                            ?>
                            <form method="POST" action="Main.php?div=addQuests" role="form">
                                        <div class="form-group">
                                            <label>Name</label>
                                            <input name="questName" class="form-control">
                                        </div>
                                <div class="form-group">
                                            <label>Starting text</label>
                                            <input name="questStart" class="form-control">
                                        </div>
                                <div class="form-group">
                                            <label>Ending text</label>
                                            <input name="questEnd" class="form-control">
                                        </div>
                                <div class="form-group">
                                            <label>Objectives</label>
                                            <input name="questObjectives" class="form-control">
                                        </div>
                                <div class="form-group">
                                            <label>Rewards</label>
                                            <input name="questRewards" class="form-control">
                                        </div>
                                <div class="form-group">
                                            <label>Required quests</label>
                                            <input name="questReq" class="form-control" value="-1">
                                        </div>
                                <div class="form-group">
                                    <label>Required level</label>
                                    <input name="reqLevel" class="form-control" value="1">
                                </div>
                                <div class="form-group">
                                            <label>Able to complete</label>
                                            <select name="questCompletion" class="form-control">
                                                <option value="1">Once</option>
                                                <option value="2">Once daily</option>
                                                <option value="3">No restrictions</option>
                                            </select>
                                        </div>

                                                                                    <div class="form-group">
                                            <label>Access</label>
                                            <select name="questAccess" class="form-control">
                                                <option value="1">Users</option>
                                                <option value="2">Members</option>
                                                <option value="3">Moderators</option>
                                                <option value="4">Staff</option>
                                                <option value="5">Administrators *</option>
                                            </select>
                                        </div>


                                        <button type="submit" class="btn btn-primary">Add quest</button>
                                    </form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->