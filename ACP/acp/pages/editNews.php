<?php
if($_POST){
$error = false;
    if(empty($_POST["newsSubject"])){
        $error = true;
        $errormsg .= "You're missing news subject<br/>";
    }
    if(empty($_POST["newsText"])){
        $error = true;
        $errormsg .= "You're missing news text<br/>";
    }
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Yo, editin' newsings, eh?</h1>
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
			$sql = "UPDATE news SET subject=:subject, newstext=:newstext WHERE id=:id";
			$q = $db->prepare($sql);
			$q->execute(array(':subject'=>$_POST["newsSubject"],
							  ':newstext'=>$_POST["newsText"],
                              ':id'=>$_GET["ien"]));
			die("Item edited.                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>");
            }


		$stmt = $db->prepare('SELECT * FROM news WHERE id=:id LIMIT 1');
		$stmt->execute(array(':id'=>$_GET["ien"]));

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                            ?>
                            <form method="POST" action="Main.php?div=editNews&ien=<?php echo $row["id"];?>" role="form">
                                        <div class="form-group">
                                            <label>Subject</label>
                                            <input name="newsSubject" value="<?php echo $row["subject"];?>" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>News</label>
                                            <textarea name="newsText" class="form-control" rows="5"><?php echo $row["newstext"];?></textarea>
                                        </div>

                                        <button type="submit" class="btn btn-success">Edit news</button>
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