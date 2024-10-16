use <BOSL/threading.scad>

module cap_38mm() {
    // this is for a 38mm thread with 3 starts, each start turning
    // just over 180 degrees

    // meaured height is exactly 10mm, so add 1 for clearance
    thread_height = 11;

    // the bottle is 38mm, so not sure how these numbers work our,
    // but they seem to work
    bottle_od=38;
    thread_id = bottle_od + 4;
    thread_od = bottle_od + 8;

    // pitch is calculated by measuring the height diference for
    // one start for 180 degrees and doubling it. Probably not
    // exact, but the thread we make here is bigger than the male
    // thread, so works OK.
    thread_pitch = 5;

    metric_trapezoidal_threaded_nut(od=thread_od, id=thread_id,
        h=thread_height, pitch=thread_pitch, starts=3,
        // these args are from the sample I found, I haven't played with them
        $slop=0.05, $fa=1, $fs=1);
}

//cap_38mm();
