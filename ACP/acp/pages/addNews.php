<?php
if($_POST){
    $error = false;
    
    if(empty($_POST["newsSubject"])){
        $error = true;
        $errormsg .= "You're missing item name<br/>";
    }
    if(empty($_POST["newsText"])){
        $error = true;
        $errormsg .= "You're missing item description<br/>";
    }
    
    $stmt2 = $db->prepare('SELECT id FROM characters WHERE username=:uname');
    $stmt2->execute(array(':uname'=>$_COOKIE["username"]));

    $result2 = $stmt2->fetchAll();
    foreach($result2 as $row2) {
        $uid = $row2["id"];
    }
}
?>
<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Yo, postin' some news, eh?</h1>
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
                $sql = "INSERT INTO news (subject, newstext, userid) VALUES (:subject, :newstext, :uid)";
                $q = $db->prepare($sql);
                $q->execute(array(':subject'=>$_POST["newsSubject"],
                                  ':newstext'=>$_POST["newsText"],
                                  ':uid'=>$uid));
                die("News added.                        </div>
                            <!-- /.panel-body -->
                        </div>
                        <!-- /.panel -->
                    </div>
                    <!-- /.col-lg-12 -->
                </div>");
            }
                            ?>
                            <form method="POST" action="Main.php?div=addNews" role="form">
                                        <div class="form-group">
                                            <label>Subject</label>
                                            <input name="newsSubject" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>News</label>
                                            <textarea name="newsText" class="form-control" rows="5"></textarea>
                                        </div>

                                        <button type="submit" class="btn btn-primary">Add news</button>
                                    </form>

                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->